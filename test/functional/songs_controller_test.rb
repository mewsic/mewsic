require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  tests SongsController

  def test_index_should_response_success
    get :index
    assert_response :success
  end
  
  def test_show_should_response_success
    get :show, :id => songs(:let_it_be)
    assert_response :success
  end
  
  def test_show_should_redirect_unless_song
    get :show, :id => 0
    assert_response :redirect
  end
  
end
