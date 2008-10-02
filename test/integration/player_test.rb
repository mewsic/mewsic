require "#{File.dirname(__FILE__)}/../test_helper"

class PlayerTest < ActionController::IntegrationTest
  fixtures :songs, :tracks

  def setup
  end

  def test_bad_behaviour_on_playcount_for_songs
    song = songs(:really_short_song)
    listened_times = song.listened_times

    get "/songs/#{song.id}/player.html"
    assert_response :success
    assert_equal listened_times, song.reload.listened_times
    assert_equal "/songs/#{song.id}/i", assigns(:playcount_path)

    put "/songs/#{song.id}/i"
    assert_response :bad_request
    assert_equal listened_times, song.reload.listened_times

    sleep song.seconds/2

    put "/songs/#{song.id}/i"
    assert_response :bad_request
    assert_equal listened_times, song.reload.listened_times
  end

  def test_legit_use_of_playcount_for_songs
    song = songs(:really_short_song)
    listened_times = song.listened_times

    get "/songs/#{song.id}/player.html"
    assert_response :success
    assert_equal listened_times, song.reload.listened_times

    sleep song.seconds/2

    put "/songs/#{song.id}/i"
    assert_response :success
    assert_equal listened_times + 1, song.reload.listened_times
  end

  def test_bad_behaviour_on_playcount_for_tracks
    track = tracks(:really_short_track)
    listened_times = track.listened_times

    get "/tracks/#{track.id}/player.html"
    assert_response :success
    assert_equal listened_times, track.reload.listened_times
    assert_equal "/tracks/#{track.id}/i", assigns(:playcount_path)

    put "/tracks/#{track.id}/i"
    assert_response :bad_request
    assert_equal listened_times, track.reload.listened_times

    sleep track.seconds/2

    put "/tracks/#{track.id}/i"
    assert_response :bad_request
    assert_equal listened_times, track.reload.listened_times
  end

  def test_legit_use_of_playcount_for_tracks
    track = tracks(:really_short_track)
    listened_times = track.listened_times

    get "/tracks/#{track.id}/player.html"
    assert_response :success
    assert_equal listened_times, track.reload.listened_times

    sleep track.seconds/2

    put "/tracks/#{track.id}/i"
    assert_response :success
    assert_equal listened_times + 1, track.reload.listened_times
  end

end
