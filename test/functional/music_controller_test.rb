require File.dirname(__FILE__) + '/../test_helper'

class MusicControllerTest < ActionController::TestCase
  tests MusicController

  # Replace this with your real tests.
  def test_index
    get :index
    
    assert assigns(:best_songs)
    assert_equal 3, assigns(:best_songs).size
    
    assert assigns(:most_used_tracks)
    assert_equal 3, assigns(:most_used_tracks).size
    
    assert assigns(:genres)
    assert_equal 5, assigns(:genres).size
    
    assert assigns(:newest_songs)
    assert_equal 3, assigns(:newest_songs).size
    
    assert assigns(:newest_answers)
    assert_equal 3, assigns(:newest_answers).size
  end
end
