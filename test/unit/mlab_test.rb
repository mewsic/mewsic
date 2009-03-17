require File.dirname(__FILE__) + '/../test_helper'

class MlabTest < ActiveSupport::TestCase
  fixtures :users, :songs, :tracks, :mlabs, :mixes
  
  def test_should_create  
    user = users(:quentin)

    items, tracks, songs = [user.mlabs, user.mlabs.tracks, user.mlabs.songs].map(&:to_a)

    assert_difference 'Mlab.count', 3 do
      create_mlab_track
      create_mlab_track
      create_mlab_song
    end

    user.reload

    assert_equal items.size  + 3, user.mlabs.to_a.size
    assert_equal tracks.size + 2, user.mlabs.tracks.to_a.size
    assert_equal songs.size  + 1, user.mlabs.songs.to_a.size
  end

  def test_should_return_playlist_items
    user = users(:quentin)
    assert_equal user.mlabs.songs + user.mlabs.tracks, Mlab.items_for(user)
  end

private

  def create_mlab_track(options = {})
    Mlab.create({:user => users(:quentin), :mixable => tracks(:sax_for_let_it_be)}.merge(options))
  end
  
  def create_mlab_song(options = {})
    Mlab.create({:user => users(:quentin), :mixable => songs(:let_it_be)}.merge(options))
  end
  
end
