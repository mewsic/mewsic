require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  tests SongsController

  # Replace this with your real tests.
  def test_index_should_redirect_to_music_controller
    get :index
    assert_redirected_to :controller  => 'music', :action => 'index'
  end
end
