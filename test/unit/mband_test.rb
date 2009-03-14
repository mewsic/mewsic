require File.dirname(__FILE__) + '/../test_helper'

class MbandTest < ActiveSupport::TestCase
  fixtures :users, :mbands, :mband_memberships

  def test_accepted_memberships
    assert mbands(:quentin_mband).memberships.accepted.all?(&:accepted_at)
  end

  def test_pending_memberships
    assert_equal [], mbands(:quentin_mband).memberships.pending
  end

  def test_breadcrumb
    assert_equal mbands(:quentin_mband).name, mbands(:quentin_mband).to_breadcrumb
  end

  def test_tracks
    mband = mbands(:mband_1)
    assert mband.tracks.all? { |t| t.kind_of?(Track) && mband.members.include(t.user) }
  end
end
