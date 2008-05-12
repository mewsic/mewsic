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
    a = Answer.create(:body => 'question', :user => users(:quentin))
    r = a.replies.create(:body => 'answer', :user => users(:quentin))
    puts 'ciao'
    post :rate, :id => r.id, :rate => 5
    assert 5, r.reload.rating_total
    assert 5, r.reload.rating_avg
    assert 1, r.reload.rating_count
    puts 'ciao 2'
    post :rate, :id => r.id, :rate => 3
    assert 3, r.reload.rating_total
    assert 3, r.reload.rating_avg
    assert 1, r.reload.rating_count
  end
  
end
