require File.dirname(__FILE__) + '/../test_helper'

class TracksControllerTest < ActionController::TestCase

  def test_index_should_response_success
    get :index
    assert_response :success
  end
  
end
