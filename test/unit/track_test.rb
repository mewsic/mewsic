require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < ActiveSupport::TestCase
  include Playable::TestHelpers

  fixtures :users, :songs, :tracks, :instruments, :mixes, :tags, :taggings

  def test_find_most_used_tracks_should_return_tracks_and_usage
    max_usage = Mix.count(:group => :track_id, :order => 'count_all DESC').first.last
    track = Track.find_most_used(:limit => 1).first

    assert_equal max_usage, track.mixes.count
    assert_equal max_usage, track.song_count
  end
  
  def test_should_act_as_rated
    assert_acts_as_rated('Track')
  end

  def test_association_with_instrument
    assert instruments(:guitar), tracks(:guitar_for_let_it_be).instrument
  end

  def test_public_and_private_named_scopes
    assert Track.public.all?(&:public?)
    assert Track.private.all?(&:private?)
  end

  def test_accessibility
    # Private track, in a song with featurings
    private_with_feat = tracks(:voice_for_red_red_wine)
    assert private_with_feat.accessible_by?(users(:john))    # Author
    deny   private_with_feat.accessible_by?(users(:quentin)) # Featuring, without song scope
    assert private_with_feat.accessible_by?(users(:quentin), # Featuring, with a song that includes the track
                                            songs(:red_red_wine_unpublished))
    deny   private_with_feat.accessible_by?(users(:quentin), # Featuring, with extraneous song
                                            songs(:let_it_be))

    # Private track, without any featuring in any song
    assert tracks(:private_track).accessible_by?(users(:quentin))
    deny   tracks(:private_track).accessible_by?(users(:john))
    deny   tracks(:private_track).accessible_by?(users(:john), songs(:private_song))
    deny   tracks(:private_track).accessible_by?(users(:john), songs(:let_it_be))

    # Public track
    assert tracks(:guitar_for_red_red_wine).accessible_by?(users(:quentin))
    assert tracks(:guitar_for_red_red_wine).accessible_by?(users(:john))
    assert tracks(:guitar_for_red_red_wine).accessible_by?(users("user_#{rand 500}".intern))
  end

  def test_taggings
    assert_equal 3, tracks(:guitar_for_let_it_be).tag_list.size
    assert_equal 2, tracks(:guitar_for_let_it_be).tag_counts.first.count
    assert_equal [tracks(:voice_for_radio_ga_ga)], tracks(:guitar_for_let_it_be).find_related_tags
  end

  def test_deleted
    s = songs(:private_song)
    t = tracks(:private_track)
    m = mixes(:private_mix)
    assert_raise(ActiveRecord::ReadOnlyRecord) { t.delete } 

    assert_nothing_raised { s.delete }
    assert_nothing_raised { t.delete }

    assert t.reload.deleted?
    assert s.reload.deleted?
    assert m.reload.deleted?
  end

  def test_destroy
    t = playable_test_filename tracks(:private_track)
    s = songs(:private_song)
    m = mixes(:private_mix)

    assert_raise(ActiveRecord::ReadOnlyRecord) { t.destroy } 
    assert_nothing_raised { t.reload; m.reload }

    assert_nothing_raised { s.delete; t.delete; t.destroy }

    assert_raise(ActiveRecord::RecordNotFound) { t.reload }
    assert_raise(ActiveRecord::RecordNotFound) { m.reload }
    assert_nothing_raised { s.reload }
    assert_equal 0, s.tracks.count
    assert s.deleted?

    assert !File.exists?(t.absolute_filename)
    assert File.exists?(s.absolute_filename)
  end

end
