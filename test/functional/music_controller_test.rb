require File.dirname(__FILE__) + '/../test_helper'

class MusicControllerTest < ActionController::TestCase
  fixtures :genres, :songs, :tracks, :mixes

  # Replace this with your real tests.
  def test_index
    get :index
    assert_response :success

    assert assigns(:best_songs)
    assert_equal 3, assigns(:best_songs).size
    
    assert assigns(:most_used_tracks)
    assert_equal 3, assigns(:most_used_tracks).size

    assert assigns(:newest)
    assert_equal 5, assigns(:newest).size
        
    assert assigns(:genre_chars)
    assert assigns(:genres)
    assert assigns(:genres).all? { |g| g.name.first.upcase == assigns(:genre_chars).first }
    assert assigns(:genres).all? { |g| g.published_songs.count > 0 }
  end
end
