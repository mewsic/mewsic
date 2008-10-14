require "#{File.dirname(__FILE__)}/../test_helper"

class PodcastsTest < ActionController::IntegrationTest
  fixtures :users, :songs

  def test_user_podcast
    get '/users/quentin/podcast.xml'
    assert_response :success

    assert_valid_podcast :nitems => 19
  end

  def test_mband_podcast
    get '/mbands/the+quentin+mband/podcast.xml'
    assert_response :success

    assert_valid_podcast :nitems => 19
  end

  def test_pcast
    get '/users/quentin/quentin.pcast'
    assert_response :success

    assert_valid_pcast
  end
end
