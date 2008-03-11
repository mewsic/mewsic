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
    
    # Le canzoni sono associate a un genere in modo casuale perciò non è possibile fare test sul numero 
    # di canzoni canzoni associate ad un genere.
    #
    #
    # assert assigns(:most_listened_songs)
    #     assert_equal 3, assigns(:most_listened_songs).size
    #     
    #     assert assigns(:prolific_users)
    #     assert_equal 3, assigns(:prolific_users).size
    #     
    #     assert assigns(:songs)
    #     assert_equal 20, assigns(:songs).size
  end
  
  
end
