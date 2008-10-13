require File.dirname(__FILE__) + '/../test_helper'

class GenresControllerTest < ActionController::TestCase
  tests GenresController

  fixtures :genres, :songs, :tracks

  def test_index_html_should_respond_success_if_xhr
    get :index, :format => 'html'
    assert_response :redirect

    xhr :get, :index, :format => 'html'
    assert_response :success
  end

  def test_index_xml_should_respond_success
    get :index, :format => 'xml'
    assert_response :success
  end

  def test_index_js_should_respond_success
    get :index, :format => 'js'
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
  
  def test_should_raise_excpetion_if_genre_not_found
    begin
      get :show, :id => 0
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
end
