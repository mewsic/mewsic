require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_find_most_used_tracks_should_return_tracks_and_usage
    assert_equal tracks(:voice_for_radio_ga_ga), Track.find_most_used.first.first
    assert_equal 2, Track.find_most_used.first.last
  end
  
  def test_association_with_parent
    assert_equal Song.find_by_title("Radio Ga Ga"), Track.find(:all).last.parent_song
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
    songs = Track.find_paginated_by_user(1, users(:aaron).id)
    assert songs.size < 8
  end 
  
end
