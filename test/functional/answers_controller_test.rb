require File.dirname(__FILE__) + '/../test_helper'

class AnswersControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  
  fixtures :users, :answers
  
  def test_sould_show_answers
    get :index
    assert_response :success
  end
  
  def test_create_should_redirect_unless_logged_in
    post :create
    assert_response :redirect
  end
  
  def test_create_should_validate_presence_of_body
    login_as :quentin
    assert_no_difference 'Answer.count' do
      post :create, :answer => {}
      assert_response :success
    end
  end
  
  def test_owner_should_update
    login_as :quentin
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => 'Hello world'}
    assert_not_nil flash[:notice]
    assert_response :redirect    
    assert_equal 'Hello world', answers(:quentin_asks_about_magic).reload.body
  end
  
  def test_owner_should_not_update_if_not_answer_owner
    login_as :user_11
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => 'Hello world'}
    assert_not_nil flash[:alert]
    assert_response :redirect    
    assert_equal 'Come si gioca a Magic The Gathering', answers(:quentin_asks_about_magic).reload.body
  end
  
  def test_owner_should_not_update_if_older_than_10_minutes
    answers(:quentin_asks_about_magic).update_attribute(:created_at, 20.minutes.ago)
    login_as :quentin
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => 'Hello world'}
    assert_not_nil flash[:alert]
    assert_response :redirect    
    assert_equal 'Come si gioca a Magic The Gathering', answers(:quentin_asks_about_magic).reload.body
  end    
  
  def test_should_create
    login_as :quentin
    quentin_answers_count = users(:quentin).answers.count
    assert_difference 'Answer.count' do
      post :create, :answer => { :body => "Waht's you name"}
      assert_response :redirect
    end
    assert_equal quentin_answers_count + 1, users(:quentin).answers.count
  end
  
end
