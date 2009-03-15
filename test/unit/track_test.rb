require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < ActiveSupport::TestCase
  include Adelao::Playable::TestHelpers

  fixtures :users, :songs, :tracks, :instruments, :mixes

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

  def test_published_and_unpublished_named_scopes
    assert Track.published.all?(&:published?)
    assert !Track.unpublished.all?(&:published?)
  end
  
  def test_should_destroy
    t = playable_test_filename(tracks(:destroyable_track))
    assert_nothing_raised { t.destroy }
    assert_raise(ActiveRecord::RecordNotFound) { Track.find(t.id) }
    assert !File.exists?(t.absolute_filename)
  end

  def test_should_destroy_mixed_track_with_unpublished_song
    t = playable_test_filename tracks(:destroyable_mixed_track)
    m = mixes(:destroyable_mix)

    assert_nothing_raised { t.destroy }
    assert_raise(ActiveRecord::RecordNotFound) { Track.find(t.id) }
    assert_raise(ActiveRecord::RecordNotFound) { Mix.find(m.id) }

    assert !File.exists?(t.absolute_filename)
  end

end
