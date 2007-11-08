require File.dirname(__FILE__) + '/../test_helper'

class DashboardControllerTest < ActionController::TestCase
  tests DashboardController

  # Replace this with your real tests.
  def test_should_render_index
    get :index
    assert_response :success
  end
end
