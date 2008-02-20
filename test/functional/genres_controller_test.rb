require File.dirname(__FILE__) + '/../test_helper'

class GenresControllerTest < ActionController::TestCase
  tests GenresController

  def test_index_should_response_success
    get :index
    assert_response :success
  end
  
  def test_show
    get :show, :id => 337050706

    assert assigns(:genre)
    
    assert assigns(:most_listened_songs)
    assert_equal 3, assigns(:most_listened_songs).size
    
    assert assigns(:prolific_users)
    assert_equal 3, assigns(:prolific_users).size
    
    assert assigns(:songs)
    assert_equal 20, assigns(:songs).size
  end
  
end
