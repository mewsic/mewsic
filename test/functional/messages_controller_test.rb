require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  
  fixtures :all
  
  def test_should_not_open_message
    get :show, :user_id => users(:quentin), :id => messages(:message_from_user_10_to_user_11)
    assert_response :success
    assert_template '_not_found'
  end
  
  def test_should_open_message
    count = users(:quentin).unread_message_count
    get :show, :user_id => users(:quentin), :id => messages(:message_for_quentin_1)
    assert_response :success
    assert_template 'show'
    assert_equal count - 1, users(:quentin).unread_message_count    
  end
  
end
