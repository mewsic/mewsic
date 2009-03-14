require File.dirname(__FILE__) + '/../test_helper'

class SongTest < ActiveSupport::TestCase
  include Adelao::Playable::TestHelpers

  fixtures :users, :songs, :mixes, :tracks

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

  def test_paginated_by_user
    songs = Song.find_paginated_by_user(1, users(:aaron))
    assert_equal 3, songs.size
  end 
  
  def test_should_not_destroy_if_has_children_tracks
    s = songs(:let_it_be)
    assert_raise(ActiveRecord::ReadOnlyRecord) { s.destroy }
    assert_not_nil s.reload
    assert File.exists?(s.absolute_filename)
  end

  def test_should_destroy_an_empty_song
    s = playable_test_filename(songs(:song_400))
    assert_nothing_raised { s.destroy }
    assert_raise(ActiveRecord::RecordNotFound) { Song.find(s.id) }
    assert !File.exists?(s.absolute_filename)
  end

end
