require File.dirname(__FILE__) + '/../test_helper'

class DashboardControllerTest < ActionController::TestCase
  tests DashboardController

  fixtures :genres, :songs, :tracks

  # Replace this with your real tests.
  def test_should_render_index
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  def test_should_render_top_myousicians
    xhr :get, :top
    assert_response :success
    assert_not_nil assigns(:people)
  end

  def test_should_render_landing_page
    %w(yt fb).each do |origin|
      get :track, :origin => origin
      assert_response :success
      assert_not_nil assigns(:people)
      assert_select 'body>script', /_trackPageview\("landing_#{origin}"\)/
    end
  end

  def test_should_no_op
    get :noop
    assert_response :success
  end

  def test_should_render_splash_config
    get :config, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:songs)
  end

end
