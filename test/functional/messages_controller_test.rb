require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :users, :messages
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
    ActionMailer::Base.deliveries = []
  end

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
    xhr :get, :index, :user_id => users(:quentin)
    assert_response :success
  end
  
  def test_index_should_redirect_if_page_bigger_then_existing_pages
    login_as :quentin
    get :index, :user_id => users(:quentin), :page => 1000
    assert_response :redirect
  end
  
  def test_should_not_open_message
    login_as :quentin
    xhr :get, :show, :user_id => users(:quentin), :id => messages(:message_from_user_10_to_user_11)
    assert_response :success
    assert_template '_not_found'
  end
  
  def test_should_open_message
    login_as :quentin
    count = users(:quentin).unread_message_count
    xhr :get, :show, :user_id => users(:quentin), :id => messages(:message_for_quentin_1)
    assert_response :success
    assert_template 'show'
    assert_equal count - 1, users(:quentin).unread_message_count    
  end
  
  def test_should_create_message
    login_as :quentin
    quentin_sent_count = users(:quentin).sent_messages.count
    user_10_received_count = users(:user_10).received_messages.count
    assert_difference 'Message.count' do
      xhr :post, :create, :user_id => users(:quentin), :message => { :subject => 'Hello', :body => 'hello world!', :to => users(:user_10).login }
    end
    assert_equal quentin_sent_count + 1,      users(:quentin).sent_messages.count
    assert_equal user_10_received_count + 1,  users(:user_10).received_messages.count
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
  
  def test_should_create_message_for_multiple_recipients
    login_as :quentin
    quentin_sent_count = users(:quentin).sent_messages.count
    user_10_received_count = users(:user_10).received_messages.count
    user_11_received_count = users(:user_11).received_messages.count
    assert_difference 'Message.count', 2 do
      xhr :post, :create, :user_id => users(:quentin), :message => { :subject => 'Hello', :body => 'hello world!', :to => "#{users(:user_10).login}, #{users(:user_11).login}" }
    end
    assert_equal quentin_sent_count + 2,      users(:quentin).sent_messages.count
    assert_equal user_10_received_count + 1,  users(:user_10).received_messages.count
    assert_equal user_11_received_count + 1,  users(:user_11).received_messages.count
  end
  
  def test_should_not_create_message
    login_as :quentin
    assert_no_difference 'Message.count' do
      post :create, :user_id => users(:quentin), :message => { :subject => 'Hello', :body => 'hello world!', :to => 'pipppppo' }
    end
  end
  
end
