require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_find_most_used_tracks_should_return_tracks_and_usage
    assert_equal tracks(:voice_for_radio_gaga), Track.find_most_used.first.first
    assert_equal 2, Track.find_most_used.first.last
  end
  
  def test_association_with_parent
    assert_equal Song.find(2), Track.find(4).parent_song
  end
  
end
