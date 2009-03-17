require File.dirname(__FILE__) + '/../test_helper'

class SongsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  include Playable::TestHelpers

  fixtures :users, :mbands, :songs, :tracks, :mixes
  
  tests SongsController

  def test_index_should_response_redirect_unless_xhr
    get :index, :user_id => users(:quentin).id, :page => 1
    assert_response :redirect
  end

  def test_index_should_response_success_if_xhr
    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:songs)
    assert_equal assigns(:songs).map(&:user).uniq, [users(:quentin)]
    assert_equal assigns(:author), users(:quentin)

    xhr :get, :index, :mband_id => mbands(:scapokkier).id
    assert_response :success
    assert assigns(:songs)
    assert_equal assigns(:songs).map(&:user).uniq, [mbands(:scapokkier)]
    assert_equal assigns(:author), mbands(:scapokkier)

    assert assigns(:songs).all?(&:public?)
  end

  def test_index_should_handle_not_found
    xhr :get, :index, :user_id => 0
    assert_response :not_found
  end
  
  def test_show_should_respond_success_for_html_xml_and_png
    get :show, :id => songs(:let_it_be)
    assert_response :success
    assert assigns(:song)
    assert_equal assigns(:song), songs(:let_it_be)

    get :show, :id => songs(:let_it_be), :format => 'xml'
    assert_response :success
    assert assigns(:song)
    assert_equal assigns(:song).id, songs(:let_it_be).id

    assert_x_accel_redirect :filename => "#{APPLICATION[:audio_url]}/#{songs(:let_it_be).filename.sub('.mp3', '.png')}", :content_type => 'image/png' do
      get :show, :id => songs(:let_it_be).id, :format => 'png'
      assert assigns(:song)
      assert_equal assigns(:song), songs(:let_it_be)
    end
  end

  def test_show_should_redirect_if_song_has_no_filename_yet
    song = songs(:let_it_be)
    song.update_attribute(:filename, nil)

    get :show, :id => song, :format => 'png'
    assert_response :redirect
  end

  def test_show_should_check_song_private_status
    # Private song with a featuring
    song = songs(:red_red_wine_unpublished)

    # Unknown user
    get :show, :id => song.id
    assert_response :forbidden

    # Author
    logout
    login_as :quentin
    get :show, :id => song.id
    assert_response :success

    # Featuring
    logout
    login_as :john
    get :show, :id => song.id
    assert_response :success
  end

  def test_should_download
    song = songs(:let_it_be)
    assert_x_accel_redirect :filename => "#{APPLICATION[:audio_url]}/#{song.filename}", :content_type => 'audio/mpeg' do
      get :download, :id => song.id
    end

    song.update_attribute :filename, nil
    get :download, :id => song.id
    assert_not_nil flash[:error]
    assert_redirected_to song_path(song)
  end

  def test_should_not_download
    get :download, :id => songs(:red_red_wine_unpublished)
    assert_response :forbidden
  end
  
  def test_show_should_redirect_unless_song
    assert_nothing_raised { get :show, :id => 0 } # id 0 means not logged in
    assert_raise(ActiveRecord::RecordNotFound) { get :show, :id => -1 }
  end

  def test_should_not_alter_public_song
    tracklist = {0 => {:id => tracks(:private_track).id, :volume => 1}}
    song = songs(:red_red_wine)

    # Test as guest
    #
    post :mix, :id => song.id, :tracks => tracklist
    assert_response :redirect

    put :update, :id => song.id, :song => {:title => 'Whatever'}
    assert_response :redirect
    assert_not_equal 'Whatever', song.reload.title

    # Test as logged in
    #
    assert_not_equal :user_42, song.user.login.intern # eh eh
    logout
    login_as :user_42
    post :mix, :id => song.id, :tracks => tracklist
    assert_response :forbidden

    put :update, :id => song.id, :song => {:title => 'Whatever'}
    assert_response :forbidden
    assert_not_equal 'Whatever', song.reload.title

    put :update, :id => -1
    assert_response :not_found

    # Test as owner
    #
    logout
    login_as song.user.login.intern
    post :mix, :id => song.id, :tracks => tracklist
    assert_response :forbidden

    put :update, :id => song.id, :song => {:title => 'Whatever'}
    assert_response :forbidden
    assert_not_equal 'Whatever', song.reload.title
  end

  def test_should_alter_private_song_if_owner_or_featuring
    song = songs(:red_red_wine_unpublished)

    current_tracks = song.tracks.clone
    tracklist = current_tracks.inject({}) { |h, track| h.update(track.id => {:id => track.id, :volume => rand}) }

    # Test as guest
    #
    post :mix, :id => song.id, :tracks => tracklist
    assert_response :redirect

    put :update, :id => song.id, :song => {:title => 'Antani'}
    assert_response :redirect

    # Test as owner
    #
    logout
    login_as :quentin

    # Sanity and solidity checks
    post :mix, :id => song.id, :tracks => []
    assert_response :bad_request
    post :mix, :id => song.id, :tracks => {}
    assert_response :bad_request
    post :mix, :id => song.id, :tracks => {:whatever => :now}
    assert_response :bad_request
    post :mix, :id => song.id, :tracks => {:id => -1, :volume => rand}
    assert_response :bad_request

    owner_added_track = tracks(:drum_for_white_christmas)
    tracklist[owner_added_track.id] = { :id => owner_added_track.id, :volume => rand }

    post :mix, :id => song.id, :tracks => tracklist
    assert_response :success
    assert_equal song.reload.tracks.map(&:id).sort, current_tracks.push(owner_added_track).map(&:id).sort

    put :update, :id => song.id, :song => {:title => 'Antani'}
    assert_response :success
    assert_equal 'Antani', song.reload.title

    put :update, :id => song.id, :song => {:title => 'Antani', :author => 'Jimmy'}
    assert_response :success
    assert_equal 'Jimmy', song.reload.author

    put :update, :id => song.id, :song => {:user_id => 0}
    assert_response :success
    assert_not_equal 0, song.reload.user_id

    put :update, :id => song.id, :song => {:listened_times => 31337}
    assert_response :success
    assert_not_equal 31337, song.reload.listened_times

    put :update, :id => song.id, :song => {:status => 42}
    assert_response :bad_request
    assert_nothing_raised { assert_not_equal 42, song.reload.status }

    # Test as featurer
    #
    logout
    login_as :john
    feat_added_track = tracks(:guitar_for_single_track_song)
    tracklist[feat_added_track.id] = { :id => feat_added_track.id, :volume => rand }

    post :mix, :id => song.id, :tracks => tracklist
    assert_response :success
    assert_equal song.reload.tracks.map(&:id).sort, current_tracks.push(feat_added_track).map(&:id).sort

    # XXX FIXME THIS IS NOT HOW IT SHOULD BE!
    put :update, :id => song.id, :song => {:title => 'Tapioca'}
    assert_response :success
    assert_equal 'Tapioca', song.reload.title

  end
  
  def test_should_rate
    login_as :quentin
    song = songs(:let_it_be)
    post :rate, :id => song.id, :rate => 2
    assert_response :success

    song = songs(:red_red_wine)
    post :rate, :id => song.id, :rate => 2
    assert_response :forbidden
  end

  def test_should_not_show_destroy_confirmation_if_not_logged_in
    xhr :get, :confirm_destroy, :id => songs(:let_it_be), :format => 'html'
    assert_response :redirect

    xhr :get, :confirm_destroy, :id => songs(:let_it_be), :format => 'js'
    assert_response :forbidden
  end

  def test_should_show_destroy_confirmation
    login_as :quentin

    xhr :get, :confirm_destroy, :id => songs(:white_christmas)
    assert_response :success
    assert_template '_destroy'
  end

  def test_should_not_show_destroy_confirmation_if_not_owns_song
    login_as :quentin

    xhr :get, :confirm_destroy, :id => songs(:let_it_be_dnb_remix)
    assert_response :forbidden
  end

  def test_should_not_destroy_if_not_logged_in
    delete :destroy, :id => songs(:let_it_be)
    assert_redirected_to login_path
  end

  def test_should_destroy_only_own_songs
    login_as :quentin
    delete :destroy, :id => songs(:let_it_be)
    assert_response :forbidden
  end

  #def test_destroy_should_unpublish_a_song_with_children_tracks
  #  login_as :quentin
  #  song = playable_test_filename(songs(:quentin_single_track_song))
  #  delete :destroy, :id => song
  #  assert_response :success
  #
  #  assert_equal false, song.reload.published
  #  assert song.mixes.empty?
  #  assert song.filename.nil?
  #end

  def test_destroy_should_delete_a_song
    song = playable_test_filename(songs(:song_50))
    login_as song.user.login.sub(/^user/, '\&_').intern

    delete :destroy, :id => song
    assert_response :success
    assert File.exists?(song.absolute_filename)
    assert song.reload.deleted?
    assert song.mixes.empty?
    assert song.tracks.empty?
  end

  def test_tracks_should_return_track_list_to_owner
    login_as :quentin

    xhr :get, :tracks, :id => songs(:red_red_wine_unpublished)
    assert_response :success
  end

  def test_tracks_should_return_track_list_to_featurers
    login_as :john

    xhr :get, :tracks, :id => songs(:red_red_wine_unpublished)
    assert_response :success
  end

  def test_tracks_should_forbid_unauthorized_access
    xhr :get, :tracks, :id => songs(:red_red_wine_unpublished)
    assert_response :forbidden
  end

end
