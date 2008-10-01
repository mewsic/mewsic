require File.dirname(__FILE__) + '/../test_helper'

class InstrumentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_find_used
    used = Instrument.find_used
    assert used.all? { |i| i.tracks.count > 0 }
  end
end
