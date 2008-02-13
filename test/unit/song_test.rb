require File.dirname(__FILE__) + '/../test_helper'

class SongTest < ActiveSupport::TestCase
  def test_association_with_children
    assert_equal 3, songs(:let_it_be).children_tracks.size
  end
  
  def test_association_with_composing_tracks
    assert_equal 4, songs(:let_it_be).tracks.size
  end
  
  def test_should_act_as_rated
    assert_acts_as_rated('Song')
  end
  
  def test_find_newest
    last_song = songs(:space_cowboy)
    songs = Song.find_newest :limit => 3
    
    assert_equal 3, songs.size
    assert_equal last_song, songs.first
  end
  
end
