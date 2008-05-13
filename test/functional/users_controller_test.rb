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
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
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
    #assert_equal 9, assigns(:coolest).size
    
    assert assigns(:best_myousicians)
    #assert_equal 3, assigns(:best_myousicians).size
    
    assert assigns(:prolific)
    #assert_equal 3, assigns(:prolific).size
    
    assert assigns(:friendliest)
    #assert_equal 1, assigns(:friendliest).size
    
    assert assigns(:most_bands)
    #assert_equal 1, assigns(:most_bands).size
    
    assert assigns(:newest)
    #assert_equal 3, assigns(:newest).size
  end
  
  def test_new
    get :new
    assert_response :success
    assert assigns(:user)
  end

  def test_should_activate_the_first_time
    assert_nil User.find(users(:aaron).id).activated_at
    get :activate, :activation_code => users(:aaron).activation_code
    assert_redirected_to :controller => 'users', :action => 'show', :id => users(:aaron).id
    assert_nil User.find(users(:aaron).id).activation_code
    assert_not_nil User.find(users(:aaron).id).activated_at
    
    get :activate, :activation_code => users(:aaron).activation_code
    assert_response :redirect
  end
  
  def test_should_raise_exception_if_user_not_found
    begin
      get :show, :id => 9999999999999
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
  def test_should_raise_exception_user_not_activated_yet
    begin
      get :show, :id => users(:aaron).id
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
  def test_should_show_activated_user
    get :show, :id => users(:quentin).id
    assert_response :success
  end
     
  def test_update_should_redirect_unless_logged_in
    post :update, :id => users(:aaron).id
    assert_response :redirect
  end
  
  def test_update_should_redirect_if_logged_in_but_different_user
    login_as :user_4
    post :update, :id => users(:aaron).id
    assert_response :redirect
  end
  
  def test_update_should_not_redirect_if_logged_in_and_current_user_page
    login_as :aaron
    post :update, :id => users(:aaron).id
    assert_response :success
  end
  
  def test_should_update_one_attribute
    login_as :aaron
    xhr :post, :update, :id => users(:aaron).id, :user => { :city => 'Milan' }
    assert_response :success
    assert_equal 'Milan', @response.body
    
    xhr :post, :update, :id => users(:aaron).id, :user => { :country => 'Italy' }
    assert_response :success
    assert_equal 'Italy', @response.body
    
    # post :update, :id => users(:aaron).id, :user => { :non_existing_field => 'Test' }
    # assert_response :success
  end

  def test_show_should_have_user_assigned
    call_and_test_show
    assert assigns(:user)
  end    
  
  def test_show_should_have_tracks_assigned
    call_and_test_show
    assert assigns(:songs)
    # assert_equal 3, assigns(:songs).size
    #     assert_equal 7, assigns(:tracks).size
  end  
  
  def test_should_redirect_unless_xhr
    get :forgot_password
    assert_response :redirect
  end
  
  def test_should_show_forgot_password
    xhr :get, :forgot_password
    assert_response :success
  end
  
  def test_should_not_send_email_if_user_email_not_found
    xhr :post, :forgot_password, :email => 'no-existing-email-no-no@test.com'
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.size    
  end
  
  def test_should_send_email_if_user_found
    xhr :post, :forgot_password, :email => users(:quentin).email
    assert_response :success
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not_nil users(:quentin).reload.password_reset_code
  end
  
  def test_should_redirect_if_code_not_found
    #users(:quentin).update_attribute(:password_reset_code, 'pippo')
    post :reset_password, :id => 'pippo'
    assert_response :redirect
    assert flash[:notice]
    assert_equal 0, ActionMailer::Base.deliveries.size      
  end
  
  def test_should_reset_password
    assert_nil User.authenticate('quentin', 'pippo')
    users(:quentin).update_attribute(:password_reset_code, 'pippo')
    post :reset_password, :id => 'pippo', :password => 'pippo', :password_confirmation => 'pippo'
    assert_redirected_to user_path(users(:quentin))
    assert flash[:notice]
    #assert_equal 1, ActionMailer::Base.deliveries.size      
    assert_nil users(:quentin).reload.password_reset_code
    assert User.authenticate('quentin', 'pippo')
  end
  
  def test_should_switch_type_to_dj
    assert_difference 'Dj.count' do
      login_as :quentin
      post :switch_type, :id => users(:quentin).id, :type => 'dj'
      assert_equal "Dj", users(:quentin).reload.type
    end
  end
  
  def test_should_switch_type_to_band
    assert_difference 'Band.count' do
      login_as :quentin
      post :switch_type, :id => users(:quentin).id, :type => 'band'
      assert_equal "Band", users(:quentin).reload.type
    end
  end
  
  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire', :terms_of_service => '1', :eula => '1' }.merge(options)
    end
    
    def call_and_test_show
      get :show, :id => users(:quentin).id
      assert_response :success
    end
end
