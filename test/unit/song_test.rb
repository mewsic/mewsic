require File.dirname(__FILE__) + '/../test_helper'

class SongTest < ActiveSupport::TestCase
  include Adelao::Playable::TestHelpers

  fixtures :users, :songs, :mixes, :tracks, :instruments, :mbands

  def test_association_with_keys
    assert_equal 3, songs(:let_it_be).children_tracks.size
  end
  
  def test_association_with_mixes
    assert_equal 3, songs(:let_it_be).tracks.size
  end

  def test_polymorphic_ownership
    assert_equal User, songs(:song_120).user.class
    assert_equal Mband, songs(:mband_song_10).user.class
  end
  
  def test_should_act_as_rated
    assert_acts_as_rated('Song')
  end

  def test_instruments
    instruments = songs(:let_it_be).instruments
    expected = [instruments(:saxophone), instruments(:guitar), instruments(:microphone)]
    assert_equal instruments.map(&:id).sort, expected.map(&:id).sort
  end

  def test_mixables
    mixables = songs(:let_it_be).mixables
    expected = [songs(:let_it_be_punk_remix), songs(:let_it_be_dnb_remix), songs(:closer_jungle_remix)]
    assert_equal mixables.map(&:id).sort, expected.map(&:id).sort

    assert songs(:let_it_be).is_mixable_with?(songs(:closer_jungle_remix))
  end

  def test_create_unpublished
    assert Song.create_unpublished!.published == false
  end

  def test_find_newest
    last_song = songs(:space_cowboy)
    songs = Song.find_newest :limit => 3
    
    assert songs.size <= 3
    assert_equal last_song, songs.first
  end

  def test_published_and_unpublished_scopes
    assert Song.published.all?(&:published?)
    assert !Song.unpublished.all?(&:published?)
  end
  
  def test_should_not_destroy_if_has_children_tracks
    s = songs(:let_it_be)
    assert_raise(ActiveRecord::ReadOnlyRecord) { s.destroy }
    assert_not_nil s.reload
    assert File.exists?(s.absolute_filename)
  end

  def test_should_destroy_an_empty_song
    s = playable_test_filename(songs(:empty_song))
    assert_nothing_raised { s.destroy }
    assert_raise(ActiveRecord::RecordNotFound) { Song.find(s.id) }
    assert !File.exists?(s.absolute_filename)
  end

end
