require File.dirname(__FILE__) + '/../test_helper'

class MultitrackControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :users, :songs

  tests MultitrackController

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
    deny   assigns(:song).new_record?

    assert_equal users(:quentin).id, assigns(:song).user_id
    assert_template 'index'
  end

  def test_index_as_guest
    get :index
    assert_response :success

    assert assigns(:song)
    assert_equal false, assigns(:song).published?
    assert assigns(:song).new_record?

    assert flash.now[:notice]
    assert stored_location

    assert_template 'index'
  end

  def test_should_remix_own_public_song
    login_as :quentin

    get :edit, :id => songs(:let_it_be).id
    assert assigns(:remix)
    assert assigns(:remix).remix_of?(songs(:let_it_be))
    assert songs(:let_it_be).remixes.include?(assigns(:remix))
    assert_redirected_to multitrack_edit_path(assigns(:remix))
  end

  def test_should_remix_any_public_song
    login_as :john

    get :edit, :id => songs(:let_it_be).id
    assert assigns(:remix)
    assert_redirected_to multitrack_edit_path(assigns(:remix))
  end

  def test_should_edit_private_song_as_owner
    login_as :quentin

    get :edit, :id => songs(:red_red_wine_unpublished).id
    assert_response :success

    assert assigns(:song)
    assert_equal songs(:red_red_wine_unpublished).id, assigns(:song).id
    assert assigns(:song).published?
    assert assigns(:song).private?
    deny   assigns(:song).new_record?

    assert_template 'index'
  end

  def test_should_edit_private_song_as_collaborator
    login_as :john

    get :edit, :id => songs(:red_red_wine_unpublished).id
    assert_response :success
    assert_template 'index'
  end

  def test_should_not_edit_unaccessible_private_song
    login_as :user_4

    get :edit, :id => songs(:red_red_wine_unpublished).id
    assert_redirected_to root_path
  end

  def test_should_not_edit_if_not_logged_in
    get :edit, :id => songs(:let_it_be).id
    assert_redirected_to login_path
  end

  def test_should_not_edit_because_invalid_song_id
    login_as :quentin
    get :edit, :id => 0

    assert_response :redirect
    assert flash[:error]
    assert_redirected_to root_path
  end

  def test_should_send_config
    get :config, :format => 'xml'

    assert_response :success
    assert_template 'config'
  end

  #def test_should_refresh
  #  get :refresh, :id => songs(:let_it_be).id
  #  assert_response :success
  #end

  def test_should_update_private_song
    get :update_song, :user_id => users(:quentin).id,
      :song_id => songs(:red_red_wine_unpublished).id,
      :filename => 'wtf.mp3', :length => 42

    assert_response :success
    song = songs(:red_red_wine_unpublished).reload

    assert song.private?
    assert song.published?

    assert_equal 'wtf.mp3', song.filename
    assert_equal 42, song.seconds
  end

  def test_should_not_update_public_song
    get :update_song, :user_id => users(:quentin).id,
      :song_id => songs(:let_it_be).id, :filename => 'sux.mp3',
      :length => 42

    assert_response :not_found
    song = songs(:let_it_be).reload
    assert_not_equal 'sux.mp3', song.filename
    assert_not_equal 42, song.seconds
  end

    # ...in order to verify that the new song administrative notice has been
    # queued. XXX song update does not imply anymore automated publishing.
    #
    #assert_equal 1, ActionMailer::Base.deliveries.size
    #ActionMailer::Base.deliveries = []

    ## And then .. update it again....
    #get :update_song, :user_id => users(:quentin).id,
    #  :song_id => songs(:red_red_wine_unpublished).id,
    #  :filename => 'test.mp3', :length => 10

    ## ...in order to verify that no new administrative notice is being generated.
    #song = song.reload
    #assert song.published?
    #assert_equal 0, ActionMailer::Base.deliveries.size
  #end

  #def test_should_send_out_collaboration_notifications
  #  song = songs(:closer)
  #  song.status = :temporary
  #  song.save
  #
  #  deny song.reload.published?
  #
  #  get :update_song, :user_id => users(:quentin),
  #    :song_id => song.id, :filename => 'test.mp3',
  #    :length => 5
  #
  #  assert_blank_response :success
  #
  #  song = song.reload
  #
  #  deny song.tracks.empty?
  #  assert_equal 5, song.seconds
  #
  #  assert_equal 3, ActionMailer::Base.deliveries.size
  #  assert_equal %w(activity@myousica.com mikaband@example.com aaron@example.com),
  #    ActionMailer::Base.deliveries.map(&:to).flatten
  #end

end
