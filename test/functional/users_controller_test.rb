require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
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

  def test_should_validate_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => 'antani$')
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
    assert_no_difference 'User.count' do
      create_user(:login => 'antani ')
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
    assert_no_difference 'User.count' do
      create_user(:login => 'aa')
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end
  
  def test_index
    get :index
    assert_response :success
    
    assert assigns(:coolest)
    #assert_equal 9, assigns(:coolest).size
    
    assert assigns(:best)
    #assert_equal 3, assigns(:best_myousicians).size
    
    assert assigns(:prolific)
    #assert_equal 3, assigns(:prolific).size
    
    assert assigns(:friendliest)
    #assert_equal 1, assigns(:friendliest).size
    
    assert assigns(:coolest_mbands)
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
    assert_redirected_to user_path(users(:aaron)) + '?welcome'
    assert_nil User.find(users(:aaron).id).activation_code
    assert_not_nil User.find(users(:aaron).id).activated_at
    assert_equal 2, ActionMailer::Base.deliveries.size
    
    get :activate, :activation_code => users(:aaron).activation_code
    assert_response :redirect
  end
  
  def test_should_redirect_to_root_and_flash_if_user_not_found
    get :show, :id => '9999999999999'
    assert flash[:error]
    assert_response :redirect
  end
  
  def test_should_redirect_to_root_and_flash_if_user_not_activated_yet
    get :show, :id => users(:aaron).id
    assert flash[:error]
    assert_response :redirect
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
    login_as :quentin
    post :update, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_update_one_attribute
    login_as :quentin

    xhr :post, :update, :id => users(:quentin).id, :user => { :city => 'Milan' }
    assert_response :success
    assert_equal 'Milan', @response.body
    assert_equal 'Milan', users(:quentin).reload.city
    
    xhr :post, :update, :id => users(:quentin).id, :user => { :country => 'Italy' }
    assert_response :success
    assert_equal 'Italy', @response.body
    assert_equal 'Italy', users(:quentin).reload.country
    
    #post :update, :id => users(:quentin).id, :user => { :non_existing_field => 'Test' }
    #assert_response 400
  end

  def test_should_return_400_status_if_validation_fails
    login_as :quentin

    xhr :post, :update, :id => users(:quentin), :user => { :city => ("A" * 400) }
    assert_response 400

    xhr :post, :update, :id => users(:quentin), :user => { :country => ("A" * 400) }
    assert_response 400
  end

  def test_show_should_have_user_assigned
    call_and_test_show
    assert assigns(:user)
  end    
  
  def test_show_should_have_ideas_and_songs_with_tracks_assigned
    call_and_test_show :format => 'html'
    assert assigns(:tracks)
    assert false # XXX FIXME
    # assert assigns(:tracks).all? { |t| t.idea? }

    assert assigns(:songs)
    assert assigns(:songs).all? { |s| s.tracks.count > 0 }
    assert assigns(:songs_count) == 10
  end
  
  def test_show_current_user_page_should_have_tracks_and_songs_assigned
    login_as :quentin

    call_and_test_show :format => 'html'
    assert assigns(:tracks)

    assert assigns(:songs)
    assert_equal 18, assigns(:songs_count)
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
    post :reset_password, :id => 'pippo'
    assert_redirected_to '/'

    assert flash[:notice] =~ /^Sorry/
    assert_equal 0, ActionMailer::Base.deliveries.size      
  end
  
  def test_should_reset_password
    assert_nil User.authenticate('quentin', 'pippo')

    users(:quentin).update_attribute(:password_reset_code, 'pippo')

    get :reset_password, :id => 'pippo'
    assert_response :success
    assert_template 'reset_password'

    post :reset_password, :id => 'pippo', :password => 'pippozzz', :password_confirmation => 'pippozzz'
    assert_redirected_to user_path(users(:quentin))

    assert flash[:notice]
    assert_equal 1, ActionMailer::Base.deliveries.size      
    assert_nil users(:quentin).reload.password_reset_code

    assert User.authenticate('quentin', 'pippozzz')
  end
  
  def test_signup_should_redirect_to_user_page_if_already_logged_in
    login_as :quentin
    get :new
    assert_redirected_to user_path(users(:quentin))
  end

  def test_countries
    xhr :get, :countries, :format => 'js'
    assert_response :success
    assert_equal 'text/javascript', @response.content_type

    countries_json = ActionView::Helpers::FormOptionsHelper::COUNTRIES.to_json
    assert_equal countries_json, @response.body

    get :countries, :format => 'xml'
    assert_response :success
  end

#  def test_should_fetch_im_contact
#    xhr :get, :im_contact, :id => users(:quentin).id, :type => 'msn'
#    assert_response :success
#    assert_select 'a.msn-link', 'quentin@example.org'
#
#    xhr :get, :im_contact, :id => users(:quentin).id, :type => 'skype'
#    assert_response :success
#    assert_select 'a.skype-link', 'skype_account'
#
#    xhr :get, :im_contact, :id => users(:aaron).id, :type => 'msn'
#    assert_response :not_found
#
#    xhr :get, :im_contact, :id => users(:user_40).id, :type => 'skype'
#    assert_response :not_found
#
#    xhr :get, :im_contact, :id => 9999999999
#    assert_response :not_found
#
#    xhr :get, :im_contact, :id => users(:quentin).id, :type => 'antani'
#    assert_response :not_found
#
#    get :im_contact, :id => users(:user_40).id, :type => 'msn'
#    assert_response :redirect
#
#    get :im_contact, :id => users(:user_40).id
#    assert_response :redirect
#  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quirezzz', :password_confirmation => 'quirezzz', :country => 'Italy'}.merge(options) # , :terms_of_service => '1', :eula => '1' }.merge(options)
    end
    
    def call_and_test_show(options = {})
      get :show, options.merge(:id => users(:quentin).id)
      assert_response :success
    end
end
