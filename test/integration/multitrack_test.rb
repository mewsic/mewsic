require "#{File.dirname(__FILE__)}/../test_helper"

class MultitrackTest < ActionController::IntegrationTest

  include AuthenticatedTestHelper
  fixtures :all  

  def test_new_song_workflow        
    session = open_session do |sess|
            
      @user = users(:quentin)      
      
      # Login
      post "/sessions", :login => 'quentin', :password => 'test'
      assert_response :redirect
      get formatted_user_mlabs_path(@user, 'xml')
      assert_response :success                              
      
      # Istanzio il multitrack
      assert_difference 'Song.count' do
        get "/multitrack"
        assert_response :success
        @song = assigns(:song)
        assert_not_nil @song
        assert !@song.new_record?
      end
      
      # Multitrack: carico 2 nuove tracce
      assert_difference 'Track.count', 2 do
        post formatted_tracks_path('xml'), :track => { :song_id => @song.id, :title => 'sample track', :tone => 'C', :instrument_id => instruments(:guitar).id }
        @track_1 = assigns(:track)
        assert_equal 'sample track', @track_1.title
        assert_equal @song.id, @track_1.song_id
        assert_equal 1, @song.children_tracks.count

        post formatted_tracks_path('xml'), :track => { :song_id => @song.id, :title => 'sample track 2', :tone => 'D', :instrument_id => instruments(:guitar).id }
        @track_2 = assigns(:track)
        assert_equal 'sample track 2', @track_2.title
        assert_equal @song.id, @track_2.song_id
        assert_equal 2, @song.children_tracks.count
      end
      
      # Multitrack: aggiungo la nuova traccia a mylist
      assert_difference 'Mlab.count' do
        assert_equal 2, @user.mlabs.count
        post formatted_user_mlabs_path(@user, 'xml'), :type => 'track', :item_id => @track_1.id
        assert_equal 3, @user.mlabs.reload.count
      end
      
      # Multitrack: salvo la canzone
      assert_equal 0, @song.tracks.count
      #post formatted_song_path(@song, 'xml'), :_method => 'put',
      post "/songs/#{@song.id}/mix",
        :song => {
          :title => 'My Song title',
          :tone => 'D',
          :seconds => 180,
          :genre_id => genres(:pop).id,
          :tracks => [
            { :id => @track_1.id },
            { :id => @track_2.id }
          ]
        }        
      assert_equal 2, @song.mixes.count
      assert_equal 2, @song.reload.tracks.count
      #assert_equal 'My Song title', @song.reload.title
                        
    end # end session
  end    

end
