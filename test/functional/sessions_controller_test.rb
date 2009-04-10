require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'test'
    assert session[:user]
    assert_response :redirect
    deny flash[:error]
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :redirect
    assert flash[:error]
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end
  
  def test_should_redirect_to_my_page
    post :create, :login => 'quentin', :password => 'test'
    assert_redirected_to user_url(users(:quentin)) 
  end

  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end


  def test_should_not_allow_connect_if_request_is_not_coming_from_facebook
    # XXX TODO
  end

  def test_should_connect_to_facebook_and_create_a_new_user

    assert_difference 'User.count' do
      request_facebook_connect(:uid => 31337)
    end

    assert_not_nil assigns(:user)
    assert_not_nil session[:user]

    user = User.find(session[:user])
    assert_equal assigns(:user), user

    assert user.valid?

    assert_equal 'fb_31337', user.login                 # XXX
    assert_equal 'unknown', user.country                # XXX
    assert_equal '31337@users.facebook.com', user.email # XXX
  end

  def test_should_connect_to_facebook_and_reuse_existing_user
    assert_difference 'User.count' do
      request_facebook_connect(:uid => 1234567)
    end

    logout

    assert_no_difference 'User.count' do
      request_facebook_connect(:uid => 1234567)
    end

    assert_not_nil session[:user]
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end

    def request_facebook_connect(options)
      get :connect, :fname => '_opener', :session => "{uid:#{options[:uid]}}"
      assert_response :success
    end
end
