require File.dirname(__FILE__) + '/../test_helper'

class ReplyTest < ActiveSupport::TestCase
  
  fixtures :users, :answers
  
  def test_should_update_counter_cache
    a = Answer.new(:body => "What's your name")
    a.user = users(:quentin)
    a.save
    assert_equal 0, a.replies_count
    r = Reply.new(:body => "My name is pippo!")
    r.user = users(:quentin)
    r.answer = a
    r.save
  end
  
  def test_should_update_answer_last_activity_at
    a = answers(:still_open_answer)
    assert_equal a.last_activity_at, a.created_at
    r = Reply.new(:body => "My name is pippo!")
    r.user = users(:quentin)
    r.answer = a
    assert_difference 'Reply.count' do            
      r.save
    end
    assert_equal a.reload.last_activity_at, r.reload.created_at
  end
end
