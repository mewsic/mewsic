require "#{File.dirname(__FILE__)}/../test_helper"

class MultitrackTest < ActionController::IntegrationTest

  include AuthenticatedTestHelper
  fixtures :users, :instruments

  def test_multitrack_workflow
    session = open_session do |sess|

      @user = users(:quentin)

      # Log in
      #
      post "/sessions", :login => 'quentin', :password => 'test'
      assert_response :redirect

      # Load the multitrack
      #
      assert_difference 'Song.count' do
        get "/multitrack"
        assert_response :success
        @song = assigns(:song)
        assert_not_nil @song
        deny @song.new_record?
      end

      # Test token authentication
      #
      auth_token = @user.reload.multitrack_token
      assert_not_nil auth_token

      post multitrack_auth_path(@user.id), :token => auth_token
      assert_response :success

      # Create two tracks
      #
      assert_difference 'Track.count', 2 do
        post formatted_tracks_path('xml'), :track => { :title => 'sample track', :instrument_id => instruments(:guitar).id, :filename => '/antani/tapioca/test.mp3', :seconds => 10 }
        assert_response :success

        @track_1 = assigns(:track)
        assert_equal 'sample track', @track_1.title
        assert @track_1.private?

        post formatted_tracks_path('xml'), :track => { :title => 'sample track 2', :instrument_id => instruments(:guitar).id, :filename => 'test.mp3', :seconds => 60 }
        assert_response :success

        @track_2 = assigns(:track)
        assert_equal 'sample track 2', @track_2.title
        assert @track_2.private?
      end

      # Save the new song information
      #
      assert_equal 0, @song.tracks.count
      put "/songs/#{@song.id}",
        :song => {
          :title => 'My Song title',
          :seconds => 180
        }
      assert_response :success

      # Save new song tracks
      #
      post "/songs/#{@song.id}/mix",
         :tracks => {
           0 => {:id => @track_1.id, :volume => 0.3},
           1 => {:id => @track_2.id, :volume => 1.0},
           2 => {:id => rand(65535), :volume => -10} # XXX REMOVE ME, SHOULD BE FIXED IN AS3
        }

      assert_response :success

      @song.reload
      assert @song.private?

      assert_equal 2, @song.mixes.count
      assert_equal 2, @song.tracks.count

      assert_equal 'My Song title', @song.title
      assert_equal 180, @song.seconds
      deny @song.filename

      mix_1 = @song.mixes.find_by_track_id(@track_1.id)
      mix_2 = @song.mixes.find_by_track_id(@track_2.id)

      assert_equal 0.3, mix_1.volume
      assert_equal 1.0, mix_2.volume

      # Update the song length and filename with the data supplied by the encoder app (multitrack-server)
      #
      post multitrack_song_path(@user.id, :song_id => @song.id, :filename => '/whatever/test.mp3', :length => 2)
      assert_response :success

      @song.reload

      assert_equal 'test.mp3', @song.filename
      assert_equal 2, @song.seconds
      assert @song.private?

      # XXX write down publishing tests
      #

      # put '/songs/' + @song.id, :song => { :status => Song.statuses.public }
      # or
      # put '/songs/' + @song.id + '/publish' <-- better ;)
      # assert_response :success
      # assert @song.reload.public?
    end
  end

end
