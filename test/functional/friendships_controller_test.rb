require File.dirname(__FILE__) + '/../test_helper'

class FriendshipsControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :friendships
  
  def test_should_route_friendships
    options = {:controller => 'friendships', :action => 'index', :user_id => users(:quentin).id.to_s }
    assert_routing "/users/#{users(:quentin).id}/friendships", options
  end
    
  def test_should_create_friendship
    login_as :quentin   
    message_count = users(:mikaband).received_messages.count
    assert_difference 'Friendship.count' do
      post :create, :user_id => users(:quentin), :friend_id => users(:mikaband).id
      assert_response :redirect
    end
    assert_equal message_count + 1, users(:mikaband).received_messages.count
  end
  
end
