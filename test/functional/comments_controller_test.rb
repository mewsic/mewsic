require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  
  fixtures :users, :answers, :comments, :songs
  tests CommentsController
 
  def test_create_should_redirect_unless_logged_in
    post :create, :answer_id => answers(:quentin_asks_about_magic).id, :comment => { :body => 'yes' }
    assert_response :redirect
  end
  
  def test_create_should_redirect_if_commentable_not_found
    login_as :quentin

    post :create, :song_id => 0, :comment => { :body => 'yes' }
    assert_response :not_found
  end
  
  def test_should_validate_presence_of_body
    login_as :quentin
    answer = answers(:quentin_asks_about_magic)
    assert_no_difference 'Comment.count' do
      post :create, :answer_id => answer.id, :comment => { :body => '' }
      assert_response :redirect
    end
  end

  def test_should_create
    login_as :quentin

    song = songs(:let_it_be)
    comments_count = song.comments.count
    quentin_comments_count = users(:quentin).writings.count

    assert_difference 'Comment.count' do
      post :create, :song_id => song.id, :comment => { :body => 'yes' }
      assert_response :redirect
    end

    assert_equal comments_count + 1, song.comments.count
    assert_equal quentin_comments_count + 1, users(:quentin).writings.count
  end
  
  def test_should_not_create_if_answer_is_closed
    login_as :quentin

    answer = answers(:closed_answer)
    comments_count = answer.comments.count
    quentin_comments_count = users(:quentin).writings.count

    assert_no_difference 'Comment.count' do
      post :create, :answer_id => answer.id, :comment => { :body => 'yes' }
      assert_response :forbidden
    end

    assert_equal comments_count, answer.comments.count
    assert_equal quentin_comments_count, users(:quentin).writings.count
  end

  def test_should_send_message_after_comment
    login_as :user_10

    message_count = users(:quentin).unread_message_count
    post :create, :answer_id => answers(:quentin_asks_about_magic).id, :comment => { :body => 'hello!' }
    assert_equal message_count + 1, users(:quentin).reload.unread_message_count
  end
  
  def test_should_rate
    login_as :quentin
    c = comments(:john_replies_to_quentins_magic_question)

    post :rate, :id => c.id, :rate => 5
    c.reload

    assert 5, c.rating_total
    assert 5, c.rating_avg
    assert 1, c.rating_count

    post :rate, :id => c.id, :rate => 3
    c.reload

    assert 3, c.rating_total
    assert 3, c.rating_avg
    assert 1, c.rating_count
  end
  
end
  

