require File.dirname(__FILE__) + '/../test_helper'

class FriendshipsControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :friendships
  
  def test_should_route_friendships
    options = {:controller => 'friendships', :action => 'index', :user_id => users(:quentin).id.to_s }
    assert_routing "/users/#{users(:quentin).id}/friendships", options
  end
    
  def test_should
    login_as :user_10   
    
    assert_difference 'Friendship.count' do
      post :create, :user_id => users(:quentin), :friend_id => users(:user_11).id
      assert_response :redirect
    end                
                         
  end
  
end