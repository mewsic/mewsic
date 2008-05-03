require File.dirname(__FILE__) + '/../test_helper'

class ReplyTest < ActiveSupport::TestCase
  
  
  def test_should_update_counter_cache
    a = Answer.create(:body => "What's your name")
    assert_equal 0, a.replies_count
    r = Reply.new(:body => "My name is pippo!")
    r.answer = a
    r.save
    assert_equal 1, a.reload.replies_count    
  end
end
