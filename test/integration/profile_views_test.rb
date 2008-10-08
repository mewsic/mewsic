require "#{File.dirname(__FILE__)}/../test_helper"
require 'ruby-debug'

class ProfileViewsTest < ActionController::IntegrationTest
  fixtures :users

  def test_profile_views
    user = users(:quentin)
    views = users(:quentin).profile_views

    20.times do |i|
      assert_difference 'ProfileView.count' do
        get user_path(user)
        assert_response :success
        assert_equal views, user.profile_views
        cookies.delete '__mt'
      end
    end

    assert_difference 'ProfileView.count' do
      10.times do |i|
        get user_path(user)
        assert_response :success
        assert_equal views, user.profile_views
      end
    end

    assert_difference 'ProfileView.count', -21 do
      ProfileView.count_and_cleanup
    end

    assert_equal views + 21, user.reload.profile_views
  end
end
