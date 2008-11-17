require File.dirname(__FILE__) + '/../test_helper'

class PlayersControllerTest < ActionController::TestCase

  fixtures :songs, :tracks

  def test_should_play_song
    xhr :get, :show, :song_id => songs(:let_it_be).id
    assert_response :success
  end
  
  def test_should_play_track
    xhr :get, :show, :track_id => tracks(:sax_for_let_it_be).id
    assert_response :success
  end
  
end
