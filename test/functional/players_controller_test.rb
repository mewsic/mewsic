require File.dirname(__FILE__) + '/../test_helper'

class PlayersControllerTest < ActionController::TestCase

  fixtures :songs, :tracks

  def test_should_increment_song_listened_times_count
    song = songs(:let_it_be)
    listened_times = song.listened_times
    xhr :get, :show, :song_id => song.id
    assert_equal listened_times + 1, song.reload.listened_times
  end
  
  def test_should_increment_track_listened_times_count
    track = tracks(:sax_for_let_it_be)
    listened_times = track.listened_times
    xhr :get, :show, :track_id => track.id
    assert_equal listened_times + 1, track.reload.listened_times
  end
  
end
