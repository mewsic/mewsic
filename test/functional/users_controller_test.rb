require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :success
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_index
    get :index
    assert_response :success
    
    assert assigns(:coolest)
    assert_equal 9, assigns(:coolest).size
    
    assert assigns(:best_myousicians)
    assert_equal 3, assigns(:best_myousicians).size
    
    assert assigns(:prolific)
    assert_equal 3, assigns(:prolific).size
    
    assert assigns(:friendliest)
    assert_equal 1, assigns(:friendliest).size
    
    assert assigns(:most_bands)
    assert_equal 1, assigns(:most_bands).size
    
    assert assigns(:newest)
    assert_equal 3, assigns(:newest).size
  end
  
  def test_new
    get :new
    assert_response :success
    assert assigns(:user)
  end
  
  def test_should_activate_the_first_time
    assert_nil User.find(users(:aaron).id).activated_at
    get :activate, :activation_code => users(:aaron).activation_code
    assert_response :success
    assert_nil User.find(users(:aaron).id).activation_code
    assert_not_nil User.find(users(:aaron).id).activated_at
    
    get :activate, :activation_code => users(:aaron).activation_code
    assert_response :redirect
  end
  
  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire', :terms_of_service => '1', :eula => '1' }.merge(options)
    end
end
