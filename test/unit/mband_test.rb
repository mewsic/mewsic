require File.dirname(__FILE__) + '/../test_helper'

class MbandTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_accepted_memberships
    assert_equal mband_memberships(:quentin_for_quentin_mband), mbands(:quentin_mband).accepted_memberships.first
  end

  def test_pending_memberships
    assert_equal [], mbands(:quentin_mband).pending_memberships
  end

  def test_breadcrumb
    assert_equal mbands(:quentin_mband).name, mbands(:quentin_mband).to_breadcrumb
  end
end
