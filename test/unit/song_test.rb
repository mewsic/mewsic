require File.dirname(__FILE__) + '/../test_helper'

class SongTest < ActiveSupport::TestCase
  include Playable::TestHelpers

  fixtures :users, :songs, :mixes, :tracks, :instruments, :mbands, :featurings

  def test_tracks_association
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

  def test_most_collaborated
    most_collaborated = Song.find_most_collaborated.first
    max_collaboration_count = Mix.count :include => :song,
      :conditions => ['track_id IN (?) and songs.id <> ? and songs.status = ?',
        most_collaborated.tracks.map(&:id), most_collaborated.id, Song.statuses.public]

    assert most_collaborated.public?
    assert max_collaboration_count, most_collaborated.mixables.size
  end

  def test_create_temporary
    assert Song.create_temporary!.temporary?
  end

  def test_find_newest
    last_song = songs(:space_cowboy)
    songs = Song.find_newest :limit => 3
    
    assert songs.size <= 3
    assert_equal last_song, songs.first
  end

  def test_public_and_private_scopes
    assert Song.public.all?(&:published?)
    assert Song.public.all?(&:public?)
    assert Song.private.all?(&:published?)
    assert Song.private.all?(&:private?)
  end

  def test_accessibility
    # Private song with featurings
    private_with_feats = songs(:red_red_wine_unpublished)

    assert private_with_feats.accessible_by?(users(:quentin)) # Author
    assert private_with_feats.accessible_by?(users(:john))    # Featuring
    deny   private_with_feats.accessible_by?(users(:user_42)) # No one

    # Private song with no feats
    assert songs(:private_song).accessible_by?(users(:quentin)) # Author
    deny   songs(:private_song).accessible_by?(users(:john))    # No one

    # Public song
    assert songs(:let_it_be).accessible_by?(users("user_#{rand 500}".intern))
  end
  
  def test_delete
    s = songs(:private_song)
    m = mixes(:private_mix)

    assert_nothing_raised { s.delete }
    assert File.exists?(s.absolute_filename)

    assert s.reload.deleted?
    assert m.reload.deleted?
  end

  def test_destroy
    s = playable_test_filename songs(:private_song)
    m = mixes(:private_mix)

    assert_raise(ActiveRecord::ReadOnlyRecord) { s.destroy } 
    assert_nothing_raised { m.reload; s.reload }

    assert_nothing_raised { s.delete; s.destroy }

    assert_raise(ActiveRecord::RecordNotFound) { s.reload }
    assert_raise(ActiveRecord::RecordNotFound) { m.reload }

    assert !File.exists?(s.absolute_filename)
  end

end
