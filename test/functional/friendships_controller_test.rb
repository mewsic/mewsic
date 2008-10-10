require File.dirname(__FILE__) + '/../test_helper'
require 'ruby-debug'

class FriendshipsControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :friendships
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    ActionMailer::Base.deliveries = []
  end

  def test_should_route_friendships
    options = {:controller => 'friendships', :action => 'index', :user_id => users(:quentin).id.to_s }
    assert_routing "/users/#{users(:quentin).id}/friendships", options
  end

  def test_should_create_friendship
    # Create admiration from quentin to mikaband
    #
    login_as :quentin

    message_count = users(:mikaband).received_messages.count

    mikaband_admirers_count = users(:mikaband).admirers.size
    mikaband_friends_count = users(:mikaband).friends.size

    assert_difference 'Friendship.count' do
      create_friendship_between(:quentin, :mikaband)
    end

    friendship = assigns(:friendship)
    assert_not_nil friendship
    assert_nil friendship.accepted_at

    assert_equal message_count + 1, users(:mikaband).received_messages.count

    assert_equal mikaband_admirers_count + 1, users(:mikaband).admirers.size
    assert_equal mikaband_friends_count, users(:mikaband).friends.size

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not_nil flash[:notice]

    logout

    # Establish friendship from mikaband to quentin
    #
    login_as :mikaband

    message_count = users(:quentin).received_messages.count
    quentin_admirers_count = users(:quentin).admirers.size
    quentin_friends_count = users(:quentin).friends.size

    assert_no_difference 'Friendship.count' do
      create_friendship_between(:mikaband, :quentin)
    end

    assert_equal friendship.reload, assigns(:friendship)
    assert_not_nil friendship.accepted_at

    assert_equal message_count + 1, users(:quentin).received_messages.count

    assert_equal quentin_admirers_count, users(:quentin).admirers.size
    assert_equal quentin_friends_count + 1, users(:quentin).friends.size

    assert_equal mikaband_admirers_count, users(:mikaband).admirers.size
    assert_equal mikaband_friends_count + 1, users(:mikaband).friends.size

    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_not_nil flash[:notice]
  end

  def test_should_destroy_friendship
    login_as :quentin

    user_3 = users(:user_3)
    quentin = users(:quentin)

    # Initialize counters
    #
    message_count = quentin.received_messages.count

    quentin_admirers_count = quentin.admirers.size
    quentin_friends_count = quentin.friends.size
    user_3_admirers_count = user_3.admirers.size
    user_3_friends_count = user_3.friends.size

    friendship = friendships(:quentin_relationship_1)

    # Destroy the friendship
    #
    assert_difference 'Friendship.count', -1 do
      destroy_user_friendship :quentin, friendship
    end

    # Do actual checks
    #
    assert_equal message_count, quentin.received_messages.count

    assert_equal quentin_admirers_count, quentin.admirers.size
    assert_equal quentin_friends_count - 1, quentin.friends.size
    assert_equal user_3_admirers_count, user_3.admirers.size
    assert_equal user_3_friends_count - 1, user_3.friends.size

    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_not_nil flash[:notice]
  end

  def test_should_break_friendship
    login_as :user_3

    # Initialize counters
    #
    user_3 = users(:user_3)
    quentin = users(:quentin)

    message_count = user_3.received_messages.count

    quentin_admirers_count = quentin.admirers.size
    quentin_friends_count = quentin.friends.size
    user_3_admirers_count = user_3.admirers.size
    user_3_friends_count = user_3.friends.size

    friendship = friendships(:quentin_relationship_1)

    # Break the friendship
    #
    assert_no_difference 'Friendship.count' do
      destroy_user_friendship :user_3, friendship
    end

    # Do actual checks
    #
    assert_equal friendship.reload, assigns(:friendship)
    assert_nil friendship.accepted_at

    assert_equal message_count, user_3.received_messages.count

    assert_equal quentin_admirers_count, quentin.admirers.size
    assert_equal quentin_friends_count - 1, quentin.friends.size
    assert_equal user_3_admirers_count + 1, user_3.admirers.size
    assert_equal user_3_friends_count - 1, user_3.friends.size

    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_not_nil flash[:notice]
  end

  protected
  def create_friendship_between(user, friend)
    post :create, :user_id => users(user).id, :friend_id => users(friend).id
    assert_response :redirect
  end

  def destroy_user_friendship(user, friendship)
    delete :destroy, :user_id => users(user).id, :id => friendship.id
    assert_response :redirect
  end

end
