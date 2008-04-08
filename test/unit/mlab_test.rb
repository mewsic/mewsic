require File.dirname(__FILE__) + '/../test_helper'

class MlabTest < ActiveSupport::TestCase

  include AuthenticatedTestHelper
  fixtures :all
  
  def test_should_create  
    quentin_mlab_items_count  = users(:quentin).mlabs.count
    quentin_mlab_tracks_count = users(:quentin).mlab_tracks.count
    quentin_mlab_songs_count  = users(:quentin).mlab_songs.count
    assert_difference 'Mlab.count', 3 do
      create_mlab_track
      create_mlab_track
      create_mlab_song
    end
    assert_equal quentin_mlab_items_count   + 3, users(:quentin).mlabs.count
    assert_equal quentin_mlab_tracks_count  + 2, users(:quentin).mlab_tracks.count
    assert_equal quentin_mlab_songs_count   + 1, users(:quentin).mlab_songs.count        
  end

private

  def create_mlab_track(options = {})
    Mlab.create({:user => users(:quentin), :mixable => tracks(:sax_for_let_it_be)}.merge(options))
  end
  
  def create_mlab_song(options = {})
    Mlab.create({:user => users(:quentin), :mixable => songs(:let_it_be)}.merge(options))
  end
  
end
