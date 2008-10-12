require File.dirname(__FILE__) + '/../test_helper'

class MultitrackControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :all

  #def setup
  #  ActionMailer::Base.delivery_method = :test
  #  ActionMailer::Base.perform_deliveries = true
  #  ActionMailer::Base.deliveries = []
  #end

  def teardown
    super
    ActionMailer::Base.deliveries = []
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
    assert assigns(:song).new_record?
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
    get :config, :format => 'xml'

    assert_response :success
    assert_template 'config'
  end

  def test_should_refresh
    get :refresh, :id => songs(:i_want_to_break_free).id
    assert_response :success
  end

  def test_should_update_song_when_encoding_completes
    # First update a song that's still not published...
    #
    get :update_song, :user_id => users(:quentin).id,
      :song_id => songs(:red_red_wine_unpublished).id,
      :filename => 'test.mp3', :length => 10

    assert_response :success
    song = songs(:red_red_wine_unpublished).reload

    # ...in order to verify that the new song notice has been sent
    #
    assert song.published?
    assert_equal 'test.mp3', song.filename
    assert_equal 10, song.seconds
    assert_equal 1, ActionMailer::Base.deliveries.size
    ActionMailer::Base.deliveries = []

    # And then .. update it again....
    get :update_song, :user_id => users(:quentin).id,
      :song_id => songs(:red_red_wine_unpublished).id,
      :filename => 'test.mp3', :length => 10

    # ...in order to verify that no new notice is being sent
    song = song.reload
    assert song.published?
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

end
