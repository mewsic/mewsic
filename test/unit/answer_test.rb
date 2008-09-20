require File.dirname(__FILE__) + '/../test_helper'

class AnswerTest < ActiveSupport::TestCase
  
  def test_should_validate_presence_of_body
    assert_no_difference 'Answer.count' do
      c = create_answer(:body => nil)
      assert c.errors.on(:body)
    end
  end
  
  def test_should_create
    assert_difference 'Answer.count' do
      a = create_answer
    end
  end
  
  def test_should_create_and_set_last_activity_at
    assert_difference 'Answer.count' do
      c = create_answer
      assert_equal c.reload.last_activity_at, c.created_at
    end
  end              
  
  def test_should_create_and_set_closed_to_false
    assert_difference 'Answer.count' do
      c = create_answer
      assert !c.closed?
    end
  end
  
  def test_should_close_answers
    closed_count = Answer.count(:conditions => ["closed = ?", true])
    assert !answers(:still_open_answer).closed?
    Answer.close_old_answers
    assert answers(:still_open_answer).reload.closed?
    assert_equal closed_count + 1, Answer.count(:conditions => ["closed = ?", true])
  end

private
  
  def create_answer(options = {})
    returning Answer.new({:body => 'lorem ipsum'}.merge(options)) do |answer|
      answer.user = users(:quentin)
      answer.save
    end
  end
  
end
