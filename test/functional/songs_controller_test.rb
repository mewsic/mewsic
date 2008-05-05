require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  fixtures :all
  
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
    begin
      get :show, :id => 0
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
  def test_should_rate
    login_as :quentin
    song = songs(:let_it_be)
    post :rate, :id => song.id, :rate => 2
  end
end
