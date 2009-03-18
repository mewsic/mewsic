require File.dirname(__FILE__) + '/../test_helper'

class TracksControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  tests TracksController
  fixtures :users, :mbands, :songs, :tracks, :mixes, :instruments

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
    ActionMailer::Base.deliveries = []
  end

  def test_index_should_response_redirect_if_not_xhr
    get :index
    assert_response :redirect
  end

  def test_index_bad_id_request
    xhr :get, :index, :some_id => -1
    assert_response :bad_request
  end

  def test_index_should_return_user_tracks
    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success
    assert_equal users(:quentin), assigns(:author)
    assert assigns(:tracks).all?(&:public?)
    assert assigns(:tracks).all? { |t| t.user == users(:quentin) }
  end

  def test_index_should_return_mband_tracks
    xhr :get, :index, :mband_id => mbands(:scapokkier).id
    assert_response :success
    assert_equal mbands(:scapokkier), assigns(:author)
    assert assigns(:tracks).all?(&:public?)
    assert assigns(:tracks).all? { |t| mbands(:scapokkier).members.include?(t.user) }
  end

  def xhr_index_should_send_only_public_tracks_if_not_current_user
    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success
    assert_equal assigns(:author), users(:quentin)
    assert assigns(:tracks)
    assert_equal [users(:quentin)], assigns(:tracks).map(&:user).uniq
    assert assigns(:tracks).all?(&:public?)
    assert_template 'users/tracks'

    xhr :get, :index, :mband_id => mbands(:quentin_mband).id
    assert_response :success
    assert_equal assigns(:author), mbands(:quentin_mband)
    assert assigns(:tracks)
    assert assigns(:tracks).all? { |t| mbands(:quentin_mband).members.map(&:user).include? t.user }
    assert assigns(:tracks).all?(&:public?)
    assert_template 'mbands/tracks'
  end

  def test_show_should_response_success
    get :show, :id => tracks(:sax_for_let_it_be), :format => 'html'
    assert_response :success
    assert assigns(:track)
    assert_equal assigns(:track).id, tracks(:sax_for_let_it_be).id

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
    assert assigns(:track)
    assert_equal assigns(:track).id, tracks(:sax_for_let_it_be).id

    track.update_attribute :filename, nil
    get :download, :id => track.id
    assert assigns(:track)
    assert_not_nil flash[:error]
    assert_redirected_to track_path(track)
  end

  def test_should_not_create_unless_logged_in
    assert_no_difference 'Track.count' do
      post :create, :track => {
        :title => 'test track',
        :seconds => 180,
        :instrument_id => instruments(:guitar).id,
        :filename => 'test.mp3'
      }
    end

    assert_redirected_to login_path
  end

  def test_should_validate
    login_as :quentin
    assert_no_difference 'Track.count' do
      post :create, :track => {
        :seconds => 180,
        :status => Track.statuses.public
      }
    end
    assert_response :bad_request
    assert assigns(:track)
    assert assigns(:track).public?
    assert assigns(:track).errors.on(:instrument_id)
    assert assigns(:track).errors.on(:title)

    assert_no_difference 'Track.count' do
      post :create, :track => { }
    end
    assert_response :bad_request
    assert assigns(:track)
    assert assigns(:track).private?
    assert assigns(:track).errors.on(:seconds)
    assert assigns(:track).errors.on(:filename)
  end

  def test_should_create
    login_as :quentin

    assert_difference 'Track.count' do
      post :create, :track => {
        :seconds => 180,
        :instrument_id => instruments(:guitar).id,
        :filename => 'test.mp3'
      }
    end

    assert_response :success
    #assert_equal 1, ActionMailer::Base.deliveries.size

    assert assigns(:track)
    assert_equal nil, assigns(:track).title
    assert_equal users(:quentin), assigns(:track).user

    assert assigns(:track).private?

    assert_difference 'Track.count' do
      post :create, :track => {
        :title => 'antani',
        :seconds => 180,
        :instrument_id => instruments(:guitar).id,
        :filename => 'test.mp3',
        :status => Track.statuses.public
      }
    end
    
    assert_response :success
    assert assigns(:track)
    assert_equal 'antani', assigns(:track).title
    assert_equal users(:quentin), assigns(:track).user
    assert_equal instruments(:guitar), assigns(:track).instrument

    assert assigns(:track).public?
  end

  def test_show_should_return_not_found_on_invalid_track
    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_rate
    login_as :quentin

    track = tracks(:voice_for_red_red_wine)
    assert_difference 'Rating.count' do
      xhr :put, :rate, :id => track.id, :rate => 2
      assert_response :success
    end
    assert_equal 2.0, assigns(:track).rating_avg.to_f

    track = tracks(:sax_for_let_it_be)
    assert_no_difference 'Rating.count' do
      xhr :put, :rate, :id => track.id, :rate => 2
      assert_response :forbidden
    end
  end

  def test_should_not_update_if_not_logged_in
    put :update, :id => tracks(:sax_for_let_it_be).id
    assert_redirected_to login_path
  end
  
  def test_should_not_update_nonexistent_track
    login_as :quentin
    put :update, :id => -1
    assert_response :not_found
  end

  def test_should_not_update_protected_attributes
    track = tracks(:sax_for_let_it_be)

    login_as :quentin
    put :update, :id => track, :track => {:user_id => users(:john).id, :listened_times => 30040}
    assert_response :success

    assert_equal track, assigns(:track).reload
    assert_equal track.user, assigns(:track).user
    assert_equal track.listened_times, assigns(:track).listened_times
    assert_not_equal 30040, track.reload.listened_times
  end

  def test_should_not_update_other_users_tracks
    login_as :quentin
    track = tracks(:voice_for_red_red_wine)

    put :update, :id => track, :track => {:title => 'pure crap'}
    assert_response :forbidden
    assert_not_equal 'pure crap', track.reload.title
  end

  def test_should_update_own_tracks
    login_as :quentin
    track = tracks(:sax_for_let_it_be)

    put :update, :id => track, :track => {:title => 'sax'}
    assert_response :success
    assert_equal 'sax', track.reload.title

    put :update, :id => track, :track => {:title => 'whatever', :seconds => 10}
    assert_response :success
    assert_equal 'whatever', track.reload.title
    assert_equal 10, track.seconds
  end

  def test_should_not_show_destroy_confirmation_if_not_logged_in
    # Not logged in
    xhr :get, :confirm_destroy, :id => tracks(:sax_for_let_it_be)
    assert_response :forbidden

    xhr :get, :confirm_destroy, :id => tracks(:sax_for_let_it_be), :format => 'html'
    assert_redirected_to :login
  end

  def test_should_not_show_destroy_confirmation_on_other_users_tracks
    login_as :quentin
    xhr :get, :confirm_destroy, :id => tracks(:voice_for_red_red_wine)
    assert_response :forbidden
  end

  def test_should_show_destroy_confirmation
    login_as :quentin
    xhr :get, :confirm_destroy, :id => tracks(:sax_for_let_it_be)
    assert_response :success
    assert_template '_destroy'
  end

  def test_should_not_destroy_if_not_logged_in
    delete :destroy, :id => tracks(:sax_for_let_it_be)
    assert_nil assigns(:track)
    assert_redirected_to login_path
  end

  def test_should_destroy_only_own_tracks
    login_as :quentin
    delete :destroy, :id => tracks(:voice_for_red_red_wine)
    assert_nil assigns(:track)
    assert_response :forbidden
  end

  def test_should_not_destroy_if_track_has_collaborations
    login_as :quentin

    # Public track
    assert_no_difference 'Track.count' do
      xhr :delete, :destroy, :id => tracks(:sax_for_let_it_be).id
      assert assigns(:track)
      assert_response :forbidden
    end
    deny tracks(:sax_for_let_it_be).reload.deleted?

    # Private track
    assert_no_difference 'Track.count' do
      xhr :delete, :destroy, :id => tracks(:private_track).id
      assert assigns(:track)
      assert_response :forbidden
    end
    deny tracks(:private_track).reload.deleted?
  end

  def test_should_destroy_unmixed_track
    login_as :quentin
    track = tracks(:destroyable_track)
    assert_no_difference 'Track.count' do
      xhr :delete, :destroy, :id => track.id
      assert_response :ok
    end
    assert File.exists?(track.absolute_filename)
    assert tracks(:destroyable_track).reload.deleted?
  end

end
