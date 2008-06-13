require File.dirname(__FILE__) + '/../test_helper'

class BandMembersControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  fixtures :users, :instruments

  def test_should_show_band_members
    get :index, :user_id => users(:mikaband).id
    assert_response :success
  end
  
  def test_should_redirect_unless_band
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_should_show_band_members
    get :index, :user_id => users(:mikaband).id
  end
  
  def test_should_not_create_unless_logged_in    
    assert_no_difference 'BandMember.count' do
      post :create, :user_id => users(:mikaband), :band_member => { :name => 'ivan', :instrument_id => instruments(:guitar).id }
      assert_response :redirect
    end
  end
  
  def test_should_not_create_if_not_band_owner
    login_as :quentin
    assert_no_difference 'BandMember.count' do
      post :create, :user_id => users(:mikaband), :band_member => { :name => 'ivan' }
      assert_response :redirect
    end
  end
  
  def test_should_create
    login_as :mikaband
    assert_difference 'BandMember.count' do
      post :create, :user_id => users(:mikaband), :band_member => { :name => 'ivan', :instrument_id => instruments(:guitar).id }
      assert_response :success
    end
  end
  
  def test_should_update
    login_as :mikaband
    post :update, :user_id => users(:mikaband), :id => band_members(:andrea), :band_member => { :name => 'Andrea 2' }
    assert_equal 'Andrea 2', band_members(:andrea).reload.name
  end
  
  def test_should_destroy
    login_as :mikaband
    assert_difference 'BandMember.count', -1 do
      post :destroy, :user_id => users(:mikaband), :id => band_members(:andrea)
      assert_response :success
    end
  end
  
end
