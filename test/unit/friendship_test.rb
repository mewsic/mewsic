require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < Test::Unit::TestCase

  fixtures :users, :friendships
  
  def test_should_update_friendship_count_on_accepted_friendship
    assert_difference(['User.find_by_login("quentin").friends_count', 'User.find_by_login("user80").friends_count'], 1, "Should add a friend") do
      users(:quentin).request_friendship_with(users(:user_80))
      users(:user_80).accept_friendship_with(users(:quentin))
    end
  end

  def test_should_update_friendship_count_on_forced_friendship
    assert_difference(['User.find_by_login("quentin").friends_count', 'User.find_by_login("user80").friends_count'], 1, "Should add a friend") do
      users(:quentin).become_friends_with(users(:user_80))
    end    
  end
  
  def test_should_update_friendship_count_on_destroyed_friendship
    users(:user_20).update_friends_count
    assert users(:quentin).is_friends_with?(users(:user_20))
    
    assert_difference(['User.find_by_login("quentin").friends_count', 'User.find_by_login("user20").friends_count'], -1, "Should decrease friends count") do
      users(:quentin).delete_friendship_with(users(:user_20))
    end
  end
  
  def test_should_create_or_accept
    Friendship.delete_all
    q = users(:quentin)
    u = users(:user_11)
    assert_difference 'Friendship.count' do
      Friendship.create_or_accept(u, q)
    end    
    assert_equal 0, q.reload.friends.size
    assert_equal 0, q.reload.pending_friends_by_me.count
    assert_equal 1, q.reload.pending_friends_for_me.count
    assert_no_difference 'Friendship.count' do
      Friendship.create_or_accept(q, u)
    end
    assert_equal 1, q.reload.friends.size
    assert_equal 0, q.reload.pending_friends_by_me.count
    assert_equal 0, q.reload.pending_friends_for_me.count
  end

end
