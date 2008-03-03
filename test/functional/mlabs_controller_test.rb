require File.dirname(__FILE__) + '/../test_helper'

class MlabsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :all
  
  def setup
    @controller = MlabController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_redirect_unless_logged_in
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_redirect_unless_logged_in_as_quetin
    login_as :user_4
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_success_if_logged_in_as_quetin
    login_as :quentin
    get :index, :user_id => users(:quentin).id
    assert_response :success
  end
  
  
  def test_should_destroy
    login_as :quentin
    assert_difference 'Mlab.count', -1 do
      post :destroy, :format => 'js', :user_id => users(:quentin).id, :id => users(:quentin).mlab_items.first.id
    end    
  end
  
end
