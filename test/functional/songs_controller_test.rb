require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :all
  
  tests SongsController

  def test_index_should_response_success
    get :index
    assert_response :success
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

end
