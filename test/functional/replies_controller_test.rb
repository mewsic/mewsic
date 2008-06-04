require File.dirname(__FILE__) + '/../test_helper'

class RepliesControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  
  fixtures :users, :answers, :replies
  
  def test_create_should_redirect_unless_logged_in
    post :create, :answer_id => answers(:quentin_asks_about_magic).id, :reply => { :body => 'yes' }
    assert_response :redirect
  end
  
  def test_create_should_redirect_if_answer_not_found
    post :create, :answer_id => 0, :reply => { :body => 'yes' }
    assert_response :redirect
  end
  
  def test_should_validates_presence_of_body
    login_as :quentin
    answer = answers(:quentin_asks_about_magic)
    assert_no_difference 'Reply.count' do
      post :create, :answer_id => answer.id, :reply => { :body => '' }
      assert_response :redirect
    end
  end
  
  def test_should_create
    login_as :quentin
    answer = answers(:quentin_asks_about_magic)
    replies_count = answer.replies.count
    quentin_replies_count = users(:quentin).replies.count
    assert_difference 'Reply.count' do
      post :create, :answer_id => answer.id, :reply => { :body => 'yes' }
      assert_response :redirect
    end
    assert_equal quentin_replies_count + 1, users(:quentin).replies.count
    assert_equal replies_count + 1, answer.replies.count
  end
  
  def test_should_rate
    login_as :quentin
    a = Answer.new(:body => 'question')
    a.user = users(:quentin)
    a.save
    r = Reply.new(:body => 'answer')
    r.answer = a
    r.user = users(:quentin)    
    r.save

    post :rate, :id => r.id, :rate => 5
    assert 5, r.reload.rating_total
    assert 5, r.reload.rating_avg
    assert 1, r.reload.rating_count

    post :rate, :id => r.id, :rate => 3
    assert 3, r.reload.rating_total
    assert 3, r.reload.rating_avg
    assert 1, r.reload.rating_count
  end
  
  def test_should_send_message_after_reply
    login_as :user_10
    message_count = users(:quentin).unread_message_count
    replies_count_cache = users(:user_10).replies_count
    assert_difference 'Reply.count' do
      post :create, :answer_id => answers(:quentin_asks_about_magic).id, :reply => {:body => 'hello!'}
      assert_equal message_count + 1, users(:quentin).reload.unread_message_count
    end
    
    assert_equal replies_count_cache + 1, users(:user_10).reload.replies_count
    
  end
  
end
