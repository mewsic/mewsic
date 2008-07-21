require File.dirname(__FILE__) + '/../test_helper'

class MultitrackControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :all
  tests MultitrackController

  def teardown
    @request.session[:user] = nil
  end

  def test_index_as_logged_in
    login_as :quentin

    get :index
    assert_response :success
    assert assigns(:song)
    assert_equal false, assigns(:song).published?
    assert !assigns(:song).new_record?
    assert_equal users(:quentin).id, assigns(:song).user_id
    assert_template 'index'
  end

  def test_index_as_guest
    get :index
    assert_response :success
    assert assigns(:song)
    assert_equal false, assigns(:song).published?
    assert !assigns(:song).new_record?
    #assert flash[:notice]
    assert_template 'index'
  end

  def test_should_edit
    login_as :quentin

    get :edit, :id => songs(:i_want_to_break_free).id
    assert assigns(:song)
    assert_equal songs(:i_want_to_break_free).id, assigns(:song).id
    assert assigns(:song).published?
    assert !assigns(:song).new_record?
    assert_template 'index'
  end

  def test_should_not_edit_because_not_logged_in
    get :edit, :id => songs(:let_it_be).id

    assert_response :redirect
    assert_redirected_to login_path
  end

  def test_should_not_edit_because_invalid_song_id
    login_as :quentin
    get :edit, :id => 0

    assert_response :redirect
    assert flash[:error]
    assert_redirected_to root_path
  end

  def test_should_not_edit_because_song_unpublished
    login_as :quentin

    get :edit, :id => songs(:red_red_wine_unpublished).id
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to root_path
  end

  def test_should_send_config
    get :config

    assert_response :success
    assert_template 'config'
  end

  def test_should_refresh
    get :refresh, :id => songs(:i_want_to_break_free).id
    assert_response :success
  end
end
