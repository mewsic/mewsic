require File.dirname(__FILE__) + '/../test_helper'

class AnswerTest < ActiveSupport::TestCase
 
  def test_find_newest
    last_answer = answers(:user_10_asks_about_girls)
    recent_answers = Answer.find_newest :limit => 3
    
    assert_equal 3, recent_answers.size
    assert_equal last_answer, recent_answers.first
    assert_equal 1, recent_answers.first.replies.size
    
  end
  
end
