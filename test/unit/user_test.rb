require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
  
  def test_compiled_location_should_work_with_blank_values
    users(:quentin).city = nil
    users(:quentin).country = nil
    assert_equal "Unknown", users(:quentin).compiled_location
    users(:quentin).city = "Modugno"
    assert_equal "Modugno", users(:quentin).compiled_location
    users(:quentin).country = "Italy"
    assert_equal "Modugno, Italy", users(:quentin).compiled_location
    users(:quentin).city = nil
    assert_equal "Italy", users(:quentin).compiled_location
  end
  
  def test_should_have_many_friends
    assert users(:quentin).respond_to?(:friends)
  end
  
  # Test to learn, learn to test
  def test_friends_for_and_by
    assert_equal [], users(:quentin).friends_for_me
    assert_equal [users(:quentin)], users(:user_20).friends_for_me
    assert_equal 50, users(:quentin).friends_by_me.size
  end
  
  def test_pending_friends_for_and_by
    assert_equal [], users(:aaron).pending_friends_for_me
    assert_equal [users(:aaron)], users(:user_58).pending_friends_for_me
    assert_equal 101, users(:aaron).pending_friends_by_me.size
  end
  
  def test_friends
    assert_equal 50, users(:quentin).friends.size
    assert_equal [users(:quentin)], users(:user_20).friends
  end
  
  def test_pending_friends
    assert_equal 101, users(:aaron).pending_friends.size
    assert_equal [users(:aaron)], users(:user_98).pending_friends
  end
  
  def test_pending_or_accepted_friends
    assert_equal 100, users(:quentin).pending_or_accepted_friends.size
  end
  
  def test_user_is_friend_with
    assert users(:quentin).is_friends_with?(users(:user_20))
    assert users(:user_20).is_friends_with?(users(:quentin))
  end
  
  # Not necessary to test user.is_pending_friends_with? and is_friends_or_pending_with?
  
  def test user_request_friendship_with
    users(:user_20).request_friendship_with users(:user_40)
    assert users(:user_20).is_pending_friends_with(:user_40)
    assert users(:user_40).is_pending_friends_with(:user_20)
  end
  
  def test_user_accept_friendship_with
    users(:user_20).request_friendship_with(users(:user_40))
    users(:user_40).accept_friendship_with(users(:user_20))
    assert User.find_by_login("user20").is_friends_with?(User.find_by_login("user40"))
  end
  
  def test_user_become_friends_with
    users(:user_20).become_friends_with(users(:user_40))
    assert User.find_by_login("user20").is_friends_with?(User.find_by_login("user40"))
  end
  
  # Sometimes this test can fail because of the rand() factor
  def test_find_random_should_return_different_collections
    assert User.find(:random, :limit => 10) != User.find(:random, :limit => 10)
  end
  
  def test_update_friends_count
    users(:quentin).update_friends_count
    assert_equal 50, users(:quentin).friends_count
  end
    
  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
