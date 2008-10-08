require "#{File.dirname(__FILE__)}/../test_helper"
require 'ruby-debug'

class TrackingCookieTest < ActionController::IntegrationTest
  fixtures :all

  def setup
    @cookie = nil
  end

  def test_tracking_cookie_remains_the_same
    assert_nil cookies['__mt']

    get root_path
    @cookie = cookies['__mt']
    assert_not_nil @cookie

    navigate_some_pages_and_check_cookie

    post sessions_path, :login => 'quentin', :password => 'test'
    assert_response :redirect
    check_tracking_cookie_validity

    navigate_some_pages_and_check_cookie

    get user_path(users(:quentin))
    assert_response :success
    check_tracking_cookie_validity

    get logout_path
    assert_response :redirect
    check_tracking_cookie_validity

    navigate_some_pages_and_check_cookie
  end

  def navigate_some_pages_and_check_cookie
    %w(music multitrack users bands_and_deejays).each do |page|
      get send("#{page}_path")
      assert_response :success
      check_tracking_cookie_validity
    end
  end

  def check_tracking_cookie_validity
    assert_equal @cookie, cookies['__mt']
  end
end
