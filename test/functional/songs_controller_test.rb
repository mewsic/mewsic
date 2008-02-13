require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  tests SongsController

  # Replace this with your real tests.
  def test_index_should_response_success
    get :index
    assert_response :success
  end
end
