require File.dirname(__FILE__) + '/../test_helper'

class BandTest < ActiveSupport::TestCase

  fixtures :users, :band_members

  def test_mikaband
    assert_equal 2, Band.find_by_login('mikaband').members.count
  end
  
end
