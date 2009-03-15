require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users, :tracks, :songs, :friendships, :pictures, :answers, :replies, :instruments

  def test_should_create_user_and_send_mail
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end
  
  def test_should_validate_login_format
    assert_no_difference 'User.count' do
      u = create_user(:login => "login with space")
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
  
  def test_should_validate_email_format
    assert_no_difference 'User.count' do
      u = create_user(:email => "example.com")
      assert u.errors.on(:email)
    end
  end
  
  #def test_should_validate_acceptance_of_terms_of_service
  #  assert_no_difference 'User.count' do
  #    u = create_user(:terms_of_service  => nil)
  #    assert u.errors.on(:terms_of_service)
  #  end
  #end

  #def test_should_validate_acceptance_of_eula
  #  assert_no_difference 'User.count' do
  #    u = create_user(:eula  => nil)
  #    assert u.errors.on(:eula)
  #  end
  #end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    u = users(:quentin).update_attribute(:login, 'quentin2')
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
  
  def test_should_have_many_friend
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
    assert_equal 100, users(:aaron).pending_friends_by_me.size
  end
  
  def test_friends
    assert_equal 50, users(:quentin).friends.size
    assert_equal [users(:quentin)], users(:user_20).friends

    assert_equal 80, users(:john).friends.size
    assert_equal [users(:john)], users(:user_220).friends
  end
  
  def test_pending_friends
    assert_equal 100, users(:aaron).pending_friends.size
    assert_equal [users(:aaron)], users(:user_98).pending_friends

    assert_equal 60, users(:john).pending_friends.size
    assert_equal [users(:john)], users(:user_300).pending_friends
  end
  
  def test_pending_or_accepted_friends
    assert_equal 100, users(:quentin).pending_or_accepted_friends.size
    assert_equal 140, users(:john).pending_or_accepted_friends.size
  end
  
  def test_user_is_friend_with
    assert users(:quentin).is_friends_with?(users(:user_20))
    assert users(:user_20).is_friends_with?(users(:quentin))
  end
  
  def test_user_request_friendship_with
    users(:user_20).request_friendship_with users(:user_40)
    assert users(:user_40).is_pending_friends_with?(users(:user_20))
    assert users(:user_20).reload.is_pending_friends_with?(users(:user_40))
  end
  
  def test_user_accept_friendship_with
    users(:user_20).request_friendship_with(users(:user_40))
    users(:user_40).accept_friendship_with(users(:user_20))
    assert users(:user_20).is_friends_with?(users(:user_40))
  end
  
  def test_user_become_friends_with
    users(:user_20).become_friends_with(users(:user_40))
    assert users(:user_20).is_friends_with?(users(:user_40))
  end
  
  # Sometimes this test can fail because of the rand() factor
  def test_find_random_should_return_different_collections
    assert User.find(:random, :limit => 10) != User.find(:random, :limit => 10)
  end
  
  def test_update_friends_count
    # implicit testing via attribute override
    assert_equal 50, users(:quentin).friends_count
  end
  
  def test_find_prolific_should_correctly_return_top_five_users
    # note: we're just testing against fixtures to check that aaron is the most prolific
    # previous test was too convoluted and quite frankly unintelligible
    assert_equal users(:quentin), User.find_prolific.first
  end
  
  def test_find_friendliest_should_return_the_friendliest_person
    User.find(:all).each {|u| u.update_friends_count}
    assert_equal Friendship.count(:conditions => 'accepted_at is not null', :group => :user_id, :order => 'count_all desc').first.last, User.find_friendliest(:limit => 1).first.friends_count
  end

  def test_find_most_admired_should_return_the_most_admired_person
    assert_equal Friendship.count(:conditions => 'accepted_at is null', :group => :friend_id, :order => 'count_all desc').first.last, User.find_most_admired(:limit => 1).first.admirers_count
  end

  def test_act_as_rated_should_be_rated
    assert_acts_as_rated('User')
  end
  
  def test_act_as_rated_should_rate
    Song.find(:all, :limit => 5).each do |song|
      song.rate(3, users(:quentin))
    end
    
    assert_equal 5, User.find_by_login('quentin').given_ratings.size
  end
        
  def test_should_retrieve_distinct_instrument
    expected = [:guitar, :microphone, :synthetizer, :turntables].map { |i| instruments(i) }
    assert_equal [], expected - users(:john).instruments
  end
  
  def test_quentin_should_have_photos
    assert_equal 4, users(:quentin).photos.size
  end
  
  def test_find_coolest_should_not_return_inactive_users
    check_finder_for_inactive(:find_coolest)
  end  
    
  def test_quentin_should_have_admirers
    assert_equal users(:quentin).admirers.size, 50
  end

  def test_quentin_should_retieve_answers_from_replies
    answers = users(:quentin).find_related_answers
    assert answers.include?(replies(:girls_reply).answer)
  end

  def test_quentin_should_not_have_duplicated_answers
    assert_equal users(:quentin).find_related_answers.size, 2
  end
  
  def test_should_return_user_with_more_instruments
    assert (users(:quentin).instruments.size > users(:aaron).instruments.size)
    assert_equal users(:quentin), User.find_most_instruments.first
  end

  # This test can randomly fail. It'll be fixed.
  def test_top_mewsicians
    users = User.find_top_mewsicians
    assert_equal 2, users.size
    assert users.all? { |u| u.tracks_count >= 2 }
    assert users.all? { |u| !u.avatar.nil? }
  end
  
  def test_finders
    finders = [:find_coolest, :find_prolific, :find_friendliest, :find_best, :find_newest]
    finders.each { |f| check_finder_for_inactive(f) }
  end
  
  def test_should_add_http_to_non_blank_links
    q = users(:quentin)
    q.photos_url = "google.com"
    q.myspace_url = "http://myspace.com"
    q.blog_url = ""
    q.save        
    
    assert_equal "http://google.com", q.reload.photos_url
    assert_equal "http://myspace.com", q.reload.myspace_url
    assert q.reload.blog_url.blank?
  end
  
  protected
    
    def check_finder_for_inactive(finder)
      results = User.send(finder, {})
      assert results.all? { |u| !u.activated_at.nil? } 
    end
    
    def create_user(options = {})
      options = { :login => 'quire', :email => 'quire@example.com', :gender => 'male',
        :password => 'quirezzz', :password_confirmation => 'quirezzz', :country => 'Italy'
      }.merge(options)

      user = User.new(options)
      user.login = options[:login]
      user.email = options[:email]
      user.save

      return user
    end
    
    def create_instrument
      instrument_1 = instruments(:guitar)
      instrument_2 = instruments(:saxophone)
      return [instrument_1, instrument_2]
    end
    
end
