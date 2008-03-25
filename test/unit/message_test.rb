require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase

  fixtures :all

  def test_should_create_message
    count = users(:user_10).sent_messages.count
    assert_difference 'Message.count' do
      message = Message.new
      message.subject = "Happy Festivus, son"
      message.body = "It's time for the Feats of Strength."
      message.sender = users(:user_10)
      message.recipient = users(:quentin)
      message.save
    end
    assert_equal count + 1, users(:user_10).reload.sent_messages.count
  end
  
  def test_should_read_message
    count = users(:quentin).unread_message_count
    m = Message.read(messages(:message_for_quentin_1).id, users(:quentin))
    assert_equal count - 1, users(:quentin).reload.unread_message_count
  end
  
  def test_should_delete_message
    
  end
  
end
