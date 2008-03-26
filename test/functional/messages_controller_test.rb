require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :all  
  
  def test_index_redirect_unless_logged
    get :index, :user_id => users(:quentin)
    assert_response :redirect
  end
  
  def test_index_redirect_if_logged_in_but_not_current_user
    login_as :user_10
    get :index, :user_id => users(:quentin)
    assert_response :redirect
  end
  
  def test_index_should_show_messages
    login_as :quentin
    get :index, :user_id => users(:quentin)
    assert_response :success
  end
  
  def test_index_should_redirect_if_page_bigger_then_existing_pages
    login_as :quentin
    get :index, :user_id => users(:quentin), :page => 1000
    assert_response :redirect
  end
  
  def test_should_not_open_message
    login_as :quentin
    get :show, :user_id => users(:quentin), :id => messages(:message_from_user_10_to_user_11)
    assert_response :success
    assert_template '_not_found'
  end
  
  def test_should_open_message
    login_as :quentin
    count = users(:quentin).unread_message_count
    get :show, :user_id => users(:quentin), :id => messages(:message_for_quentin_1)
    assert_response :success
    assert_template 'show'
    assert_equal count - 1, users(:quentin).unread_message_count    
  end
  
end
