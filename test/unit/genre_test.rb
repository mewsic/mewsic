require File.dirname(__FILE__) + '/../test_helper'

class GenreTest < ActiveSupport::TestCase
  
  def test_find_paginated
    assert_equal 5, Genre.find_paginated(1).size
  end
  
end
