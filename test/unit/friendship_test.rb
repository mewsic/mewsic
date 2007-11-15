require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < Test::Unit::TestCase
  fixtures :all
  
  def setup
    users(:quentin).update_friends_count
    users(:user_80).update_friends_count
  end

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
    
    assert_difference(['User.find_by_login("quentin").friends_count', 'User.find_by_login("user20").friends_count'], -1, "Should decrease friends count") do
      users(:quentin).delete_friendship_with(users(:user_20))
    end
  end

end
