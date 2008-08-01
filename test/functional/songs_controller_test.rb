require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  include Adelao::Playable::TestHelpers

  fixtures :all
  
  tests SongsController

  def test_index_html_should_response_redirect
    get :index, :format => 'html'
    assert_response :redirect
  end

  def test_index_xml_should_response_success
    get :index, :format => 'xml'
    assert_response :not_found

    get :index, :format => 'xml', :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:songs)
    assert_equal assigns(:songs).map(&:user_id).uniq.first, users(:quentin).id
  end

  def xhr_index_should_response_success
    xhr :get, :index, :genre_id => genres(:acid_punk).id
    assert_response :success
    assert_equal assigns(:genre).id, genres(:acid_punk).id
    assert assigns(:songs)
    assert_equal assigns(:songs).map(&:genre_id).uniq.first, genres(:acid_punk).id

    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success
    assert_equal assigns(:user).id, genres(:quentin).id
    assert assigns(:songs)
    assert_equal assigns(:songs).map(&:user_id).uniq.first, users(:quentin).id

    xhr :get, :index, :mband_id => mbands(:quentin_mband).id
    assert_response :success
    assert_equal assigns(:mband).id, genres(:quentin_mband).id
    assert assigns(:songs)
    assert assigns(:songs).all? { |s| mbands(:quentin_mband).members.map(&:user_id).include? s.user_id }
  end
  
  def test_show_should_response_success
    get :show, :id => songs(:let_it_be)
    assert_response :success
  end
  
  def test_show_should_redirect_unless_song
    begin
      get :show, :id => 0
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
  def test_should_rate
    login_as :quentin
    song = songs(:let_it_be)
    post :rate, :id => song.id, :rate => 2
    assert_response :success
  end

  def test_should_load_and_unload_tracks_as_authenticated
    login_as :quentin

    song = users(:quentin).songs.create_unpublished!
    load_and_unload_from(song)
  end

  def test_should_load_and_unload_tracks_as_guest
    song = Song.create_unpublished!
    load_and_unload_from(song)
  end

  def load_and_unload_from(song)
    track = tracks(:voice_for_let_it_be)

    put :load_track, :id => song.id, :track_id => track.id
    assert_response :success

    song.reload
    assert_equal song.mixes.count, 1
    assert_equal song.mixes.first.track, track
    assert_equal song.seconds, track.seconds

    put :unload_track, :id => song.id, :track_id => track.id
    assert_response :success

    song.reload
    assert_equal song.mixes.count, 0
  end

  def test_should_not_destroy_if_not_logged_in
    delete :destroy, :id => songs(:let_it_be)
    assert_redirected_to login_path
  end

  def test_should_destroy_only_own_songs
    login_as :quentin
    delete :destroy, :id => songs(:let_it_be)
    assert_response :not_found
  end

  def test_destroy_should_unpublish_a_song_with_children_tracks
    login_as :quentin
    song = playable_test_filename(songs(:quentin_single_track_song))
    delete :destroy, :id => song
    assert_response :success

    assert_equal false, song.reload.published
    assert song.mixes.empty?
    assert song.filename.nil?
  end

  def test_destroy_should_destroy_an_empty_song
    song = playable_test_filename(songs(:song_366))
    login_as song.user.login.sub(/^user/, '\&_').intern
    delete :destroy, :id => song
    assert_response :success
    assert !File.exists?(song.absolute_filename)
  end

end
