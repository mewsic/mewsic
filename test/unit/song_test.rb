require File.dirname(__FILE__) + '/../test_helper'

class SongTest < ActiveSupport::TestCase
  def test_association_with_children
    assert_equal 3, songs(:let_it_be).children_tracks.size
  end
  
  def test_association_with_composing_tracks
    assert_equal 4, songs(:let_it_be).tracks.size
  end
end
