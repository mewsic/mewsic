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
        post formatted_tracks_path('xml'), :track => { :song_id => @song.id, :title => 'sample track', :tone => 'C', :instrument_id => instruments(:guitar).id, :filename => '/antani/tapioca/test.mp3' }
        assert_response :success

        @track_1 = assigns(:track)
        assert_equal 'sample track', @track_1.title
        assert_equal @song.id, @track_1.song_id
        assert_equal 1, @song.children_tracks.count

        post formatted_tracks_path('xml'), :track => { :song_id => @song.id, :title => 'sample track 2', :tone => 'D', :instrument_id => instruments(:guitar).id, :filename => 'test.mp3' }
        assert_response :success

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
      put "/songs/#{@song.id}",
        :song => {
          :title => 'My Song title',
          :tone => 'D',
          :seconds => 180,
          :genre_id => genres(:pop).id,
         }
      assert_response :success

      post "/songs/#{@song.id}/mix",
         :tracks => {
           0 => {:id => @track_1.id, :volume => 0.3, :balance =>  1.3},
           1 => {:id => @track_2.id, :volume => 1.0, :balance => -0.4}
        }

      assert_response :success

      assert_equal 2, @song.mixes.count
      assert_equal 2, @song.reload.tracks.count

      @song.reload

      assert_equal 'My Song title', @song.title
      assert_equal 'D', @song.tone
      assert_equal 180, @song.seconds
      assert_equal genres(:pop), @song.genre

      mix_1 = @song.mixes.find_by_track_id(@track_1.id)
      mix_2 = @song.mixes.find_by_track_id(@track_2.id)

      assert_equal 0.3, mix_1.volume
      assert_equal 1.3, mix_1.balance

      assert_equal 1.0, mix_2.volume
      assert_equal -0.4, mix_2.balance
                        
    end # end session
  end    

end
