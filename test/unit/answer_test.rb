require File.dirname(__FILE__) + '/../test_helper'

class AnswerTest < ActiveSupport::TestCase
 
  def test_find_newest
    assert_equal 3, Answer.find_newest(:limit => 3).size
  end
  
end
