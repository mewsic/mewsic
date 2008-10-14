require File.dirname(__FILE__) + '/../test_helper'

class PodcastsControllerTest < ActionController::TestCase
  fixtures :users, :songs, :mbands, :mband_memberships

  def test_user_pcast
    get :pcast, :user_id => users(:quentin).id
    assert_response :success
    assert_valid_pcast
  end

  def test_user_podcast
    get :show, :user_id => users(:quentin).id
    assert_response :success

    assert_valid_podcast :nitems => 19
  end

  def test_mband_podcast
    get :show, :mband_id => mbands(:quentin_mband).id
    assert_response :success

    assert_valid_podcast :nitems => 19
  end

end
