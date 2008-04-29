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
