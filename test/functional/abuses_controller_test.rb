require File.dirname(__FILE__) + '/../test_helper'

class AbusesControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :answers, :songs, :tracks
    
  def test_should_new_redirect_if_request_is_get
    login_as :quentin
    get :new, :answer_id => answers(:quentin_asks_about_magic).id
    assert_response :success
  end

  def test_should_check_for_abuseable
    login_as :quentin
    get :new, :song_id => 0
    assert_response :bad_request

    login_as :quentin
    get :new, :answer_id => 0
    assert_response :bad_request

    login_as :quentin
    get :new, :track_id => 0
    assert_response :bad_request

    login_as :quentin
    get :new, :user_id => 0
    assert_response :bad_request
  end

  def test_should_show_get_and_assign_abuse_to_answer
    login_as :quentin
    xhr :get, :new, :answer_id => answers(:quentin_asks_about_magic).id
    assert_response :success
    assert_equal Answer, assigns(:abuseable).class
  end
  
  def test_should_create_and_assign_abuse_to_answer
    login_as :quentin
    assert_difference 'Abuse.count' do
      xhr :post, :create, :answer_id => answers(:quentin_asks_about_magic).id
      assert_response :success
      assert_equal Answer, assigns(:abuse).abuseable.class
    end
  end
    
  def test_should_show_get_and_assign_abuse_to_user
    login_as :quentin
    xhr :get, :new, :user_id => users(:john).id
    assert_response :success
    assert_equal User, assigns(:abuseable).class
  end
      
  def test_should_create_and_assign_abuse_to_user
    login_as :quentin
    assert_difference 'Abuse.count' do
      xhr :post, :create, :user_id => users(:john).id
      assert_response :success
      assert_equal User, assigns(:abuse).abuseable.class
    end
  end
    
  def test_should_show_get_and_assign_abuse_to_song
    login_as :quentin
    xhr :get, :new, :song_id => songs(:let_it_be).id
    assert_response :success
    assert_equal Song, assigns(:abuseable).class
  end
      
  def test_should_create_and_assign_abuse_to_song
    login_as :quentin
    assert_difference 'Abuse.count' do
      xhr :post, :create, :song_id => songs(:let_it_be).id
      assert_response :success
      assert_equal Song, assigns(:abuse).abuseable.class
    end
  end
    
  def test_should_show_get_and_assign_abuse_to_track
    login_as :quentin
    xhr :get, :new, :track_id => tracks(:sax_for_let_it_be).id
    assert_response :success
    assert_equal Track, assigns(:abuseable).class
  end
      
  def test_should_create_and_assign_abuse_to_track
    login_as :quentin
    assert_difference 'Abuse.count' do
      xhr :post, :create, :track_id => tracks(:sax_for_let_it_be).id
      assert_response :success
      assert_equal Track, assigns(:abuse).abuseable.class
    end
  end
  
  def test_should_create_and_send_email
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    login_as :quentin
    xhr :post, :create, :answer_id => answers(:quentin_asks_about_magic).id
    assert_response :success
    assert assigns(:abuseable)
    assert assigns(:abuse)
    assert_equal 1, ActionMailer::Base.deliveries.size

    xhr :post, :create, :answer_id => answers(:quentin_asks_about_magic).id
    assert_response :success
    assert assigns(:exists)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_template 'new'
  end
  
end
