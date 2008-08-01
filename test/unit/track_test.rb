require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < ActiveSupport::TestCase
  include Adelao::Playable::TestHelpers

  def test_find_most_used_tracks_should_return_tracks_and_usage
    track = Track.find_most_used(:limit => 1).first
    assert_equal tracks(:keyboards_for_billie_jean_by_michael_jackson), track
    assert_equal 4, track.song_count
  end
  
  def test_association_with_parent
    assert_equal songs(:radio_ga_ga), tracks(:voice_for_radio_ga_ga).parent_song
  end
  
  def test_should_act_as_rated
    assert_acts_as_rated('Track')
  end

  def test_association_with_instrument
    assert instruments(:guitar), tracks(:guitar_for_let_it_be).instrument
  end

  def test_should_not_have_genre
    t = Track.find_by_title("Basso")
    assert !t.respond_to?(:genre)
  end
  
  def test_paginated_by_user
    songs = Track.find_paginated_by_user(1, users(:aaron))
    assert songs.size < 8
  end
  
  def test_should_find_user
    t = tracks(:drums_for_billie_jean_by_pilu)    
    assert_equal t.parent_song.user, t.user
    t.user = users(:mikaband)
    t.save
    assert_not_equal t.parent_song.user, t.user
    assert_equal users(:mikaband), t.user
    assert_equal users(:quentin), t.parent_song.user
  end
  
  def test_should_set_key_from_tonality
    t = tracks(:drums_for_billie_jean_by_pilu)
    t.tonality = 'B'
    t.save
    
    assert_equal 11, t.reload.key
  end

  def test_should_destroy
    t = playable_test_filename(tracks(:random_track_23))
    assert_nothing_raised { t.destroy }
    assert_raise(ActiveRecord::RecordNotFound) { Track.find(t.id) }
    assert !File.exists?(t.absolute_filename)
  end
  
end
