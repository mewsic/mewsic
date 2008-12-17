require File.dirname(__FILE__) + '/../test_helper'

class TracksControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  include Adelao::Playable::TestHelpers

  fixtures :users, :songs, :tracks, :genres, :mixes, :instruments

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
    ActionMailer::Base.deliveries = []
  end

  def test_index_should_response_redirect
    get :index, :id => users(:quentin).id
    assert_response :redirect
  end

  def xhr_index_should_send_ideas_if_not_current_user
    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success
    assert_equal assings(:user).id, genres(:quentin).id
    assert assigns(:tracks)
    assert_equal assigns(:tracks).map(&:user_id).uniq.first, users(:quentin).id
    assert assigns(:tracks).all { |t| t.idea? }
    assert assigns(:tracks_count)
    assert_equal assigns(:tracks_count), users(:quentin).ideas_count

    xhr :get, :index, :mband_id => mbands(:quentin_mband).id
    assert_response :success
    assert_equal assings(:mband).id, genres(:quentin_mband).id
    assert assigns(:tracks)
    assert_equal assigns(:tracks).all? { |t| mbands(:quentin_mband).members.map(&:user_id).include? t.user_id }
    assert assigns(:tracks).all { |t| t.idea? }
    assert assigns(:tracks_count)
    assert_equal assings(:tracks_count), mbands(:quentin_mband).ideas_count
  end

  def xhr_index_should_send_tracks_if_not_current_user
    login_as :quentin

    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success
    assert_equal assings(:user).id, genres(:quentin).id
    assert assigns(:tracks)
    assert_equal assigns(:tracks).map(&:user_id).uniq.first, users(:quentin).id
    assert assigns(:tracks_count)
    assert_equal assigns(:tracks_count), users(:quentin).tracks_count

    xhr :get, :index, :mband_id => mbands(:quentin_mband).id
    assert_response :success
    assert_equal assings(:mband).id, genres(:quentin_mband).id
    assert assigns(:tracks)
    assert_equal assigns(:tracks).all? { |t| mbands(:quentin_mband).members.map(&:user_id).include? t.user_id }
    assert assigns(:tracks_count)
    assert_equal assings(:tracks_count), mbands(:quentin_mband).tracks_count
  end

  def test_show_should_response_success
    get :show, :id => tracks(:sax_for_let_it_be), :format => 'html'
    assert_response :redirect

    get :show, :id => tracks(:sax_for_let_it_be), :format => 'xml'
    assert_response :success
    assert assigns(:track)
    assert_equal assigns(:track).id, tracks(:sax_for_let_it_be).id

    assert_x_accel_redirect :filename => "#{APPLICATION[:audio_url]}/#{tracks(:sax_for_let_it_be).filename.sub('.mp3', '.png')}", :content_type => 'image/png' do
      get :show, :id => tracks(:sax_for_let_it_be), :format => 'png'
    end

    assert assigns(:track)
    assert_equal assigns(:track).id, tracks(:sax_for_let_it_be).id
  end

  def test_should_download
    track = tracks(:sax_for_let_it_be)
    assert_x_accel_redirect :filename => "#{APPLICATION[:audio_url]}/#{track.filename}", :content_type => 'audio/mpeg' do
      get :download, :id => track.id
    end
  end

  def test_should_not_create_unless_logged_in
    assert_no_difference 'Track.count' do
      post :create, :track => {
        :title => 'test track',
        :tonality => 'C',
        :seconds => 180,
        :song_id => songs(:let_it_be).id,
        :instrument_id => instruments(:guitar).id
      }
    end
    assert_redirected_to login_path
  end

  def test_should_validate
    login_as :quentin
    assert_no_difference 'Track.count' do
      post :create, :track => {
        :title => 'test track',
        :tonality => 'C',
        :seconds => 180
      }
    end
    assert_response :bad_request
    assert assigns(:track)
    assert assigns(:track).errors.on(:song_id)
    assert assigns(:track).errors.on(:instrument_id)
    assert assigns(:track).errors.on(:filename)

    assert_no_difference 'Track.count' do
      post :create, :track => {
        :title => 'test track',
        :tonality => 'C',
        :seconds => 180,
        :song_id => 0,
        :instrument_id => 0
      }
    end
    assert_response :bad_request
    assert assigns(:track)
    assert assigns(:track).errors.on(:instrument_id)
    assert assigns(:track).errors.on(:song_id)
    assert assigns(:track).errors.on(:filename)
  end

  def test_should_create
    login_as :quentin

    assert_difference 'Track.count' do
      post :create, :track => {
        :title => 'test track',
        :tonality => 'C',
        :seconds => 180,
        :song_id => songs(:let_it_be).id,
        :instrument_id => instruments(:guitar).id,
        :filename => 'test.mp3'
      }
    end

    assert_response :success
    assert_equal 1, ActionMailer::Base.deliveries.size

    assert assigns(:track)
    assert_equal assigns(:track).title, 'test track'
    assert_equal assigns(:track).user_id, users(:quentin).id
  end

  def test_show_should_raise_exception_unless_track
    begin
      get :show, :id => 0
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end

  def test_toggle_idea_should_redirect_if_not_logged_in
    put :toggle_idea, :id => tracks(:guitar_for_closer).id
    assert_redirected_to new_session_path
  end

  def test_toggle_idea_should_redirect_current_user_is_not_the_track_user
    login_as :user_10
    put :toggle_idea, :id => tracks(:guitar_for_closer).id
    assert_redirected_to new_session_path
  end

  def test_toggle_idea_should_toggle_idea
    login_as :quentin
    t = tracks(:guitar_for_closer)
    is_idea = t.idea?

    xhr :put, :toggle_idea, :id => t.id
    assert_response :success
    assert_not_equal is_idea, t.reload.idea?

    put :toggle_idea, :id => t.id
    assert_redirected_to user_path(users(:quentin))
    assert_equal is_idea, t.reload.idea?
  end

  def test_toggle_idea_should_toggle_idea_and_render_js
    login_as :quentin
    t = tracks(:guitar_for_closer)
    is_idea = t.idea?
    xhr :put, :toggle_idea, :id => t.id
    assert_response :success
  end

  def test_should_not_show_destroy_confirmation_if_not_logged_in
    xhr :get, :confirm_destroy, :id => tracks(:sax_for_let_it_be)
    assert_response :redirect
  end

  def test_should_show_destroy_confirmation
    login_as :quentin
    xhr :get, :confirm_destroy, :id => tracks(:sax_for_let_it_be)
    assert_response :success
    assert_template '_destroy'
  end

  def test_should_not_destroy_if_not_logged_in
    delete :destroy, :id => tracks(:sax_for_let_it_be)
    assert_redirected_to login_path
  end

  def test_should_destroy_only_own_tracks
    login_as :quentin
    delete :destroy, :id => tracks(:drum_for_closer)
    assert_response :not_found
  end

  def test_should_not_destroy_if_track_has_collaborations
    login_as :quentin
    track = tracks(:sax_for_let_it_be)
    assert_no_difference 'Track.count' do
      delete :destroy, :id => track.id
      assert_response :forbidden
    end
  end

  def test_should_destroy
    login_as :quentin
    track = playable_test_filename(tracks(:destroyable_track))
    assert_difference 'Track.count', -1 do
      delete :destroy, :id => track.id
      assert_response :ok
    end
    assert !File.exists?(track.absolute_filename)
  end

  def test_should_destroy_mixed_track_with_unpublished_song
    login_as :quentin

    4.times do |i|
      track = playable_test_filename(tracks("destroyable_mixed_track_#{i}"))
      songs = track.songs.each { |s| playable_test_filename(s) }
      mixes = track.mixes.dup

      delete :destroy, :id => track.id
      assert_response :ok

      assert_raise(ActiveRecord::RecordNotFound) { Track.find track.id }
      assert_raise(ActiveRecord::RecordNotFound) { Song.find songs.map(&:id) } if songs.size > 0
      assert_raise(ActiveRecord::RecordNotFound) { Mix.find mixes.map(&:id) } if mixes.size > 0

      assert !File.exists?(track.absolute_filename)
      songs.each { |song| assert !File.exists?(song.absolute_filename) }
    end
  end

end
