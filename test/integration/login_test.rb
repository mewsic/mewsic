require "#{File.dirname(__FILE__)}/../test_helper"

class LoginTest < ActionController::IntegrationTest

  fixtures :users, :songs

  def test_login_from_dashboard_should_redirect_to_user_page
    get root_path
    log_in
    assert_redirected_to user_path(users(:quentin))
  end

  def test_login_from_random_song_page_should_redirect_to_former_page
    random_song_path = song_path Song.find(:first, :conditions => ['published = ?', true], :order => SQL_RANDOM_FUNCTION)
    get random_song_path
    log_in
    assert_redirected_to random_song_path
  end

  def test_login_from_login_page_should_redirect_to_user_page
    get login_path
    log_in
    assert_redirected_to user_path(users(:quentin))
  end

  private
    def log_in
      post sessions_path, :login => 'quentin', :password => 'test'
      assert_response :redirect
    end
end
