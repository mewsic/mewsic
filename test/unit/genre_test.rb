require File.dirname(__FILE__) + '/../test_helper'
class GenreTest < ActiveSupport::TestCase

  fixtures :genres, :users, :songs
  
  def test_find_paginated
    assert_equal 5, Genre.find_paginated(1).size
  end
    
  def test_most_listened_songs
    genre = Genre.find_by_name("Rock")
    most_listened_song_for_rock = Song.find_by_title("I Want to Break Free")
    most_listened_songs = genre.find_most_listened :limit => 3, :include => :user
    
    assert_equal 3, most_listened_songs.size
    assert_not_nil most_listened_songs.first.user
    assert_equal most_listened_songs.first, most_listened_song_for_rock
  end
  
  def test_prolific_users
    genre = Genre.find_by_name("Reggae")
    #prolific_user = User.find_by_login("aaron")
    prolific_users = genre.find_most_prolific_users :limit => 3
    
    assert_equal 3, prolific_users.size
    assert_not_nil prolific_users.first
    #assert_equal prolific_users.first, prolific_user
  end
  
  def test_genre_songs
    genre = Genre.find_by_name("Reggae")
    songs = Song.find_paginated_by_genre(1, genre)
    assert_equal genre.published_songs.size > 15 ? 15 : genre.published_songs.size, songs.size
  end  
end
