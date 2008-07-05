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
    
    assert songs.size <= 3
    assert_equal last_song, songs.first
  end

  def test_paginated_by_genre
    songs = Song.find_paginated_by_genre(1, genres(:reggae))
    assert_equal (genres(:reggae).songs.size > 15 ? 15 : genres(:reggae).songs.size), songs.size
  end 

  def test_paginated_by_user
    songs = Song.find_paginated_by_user(1, users(:aaron))
    assert_equal 3, songs.size
  end 
  
  def test_direct_siblings
    song = songs(:gravity_blast_beat_jungle_remix)
    #assert_equal 2, song.direct_siblings.size
    track = tracks(:drum_for_gravity_blast_beat)
    #puts track.mixes.count
  end
  
  def test_is_a_direct_sibling_should_correctly_find_direct_siblings
    assert songs(:billie_jean_by_michael_jackson).is_a_direct_sibling_of?(songs(:billie_jean_by_giovanni))
    deny songs(:billie_jean_by_michael_jackson).is_a_direct_sibling_of?(songs(:billie_jean_by_pilu))
    assert songs(:billie_jean_by_pilu).is_a_direct_sibling_of?(songs(:billie_jean_by_giovanni))
  end
end
