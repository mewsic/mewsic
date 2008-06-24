require File.dirname(__FILE__) + '/../test_helper'

class MbandMembershipsControllerTest < ActionController::TestCase
  
  fixtures :all
  include AuthenticatedTestHelper

  def test_should_create    
    login_as :quentin
    assert_difference 'Mband.count' do
      @mband = Mband.create(:name => 'my mband')
      membership = MbandMembership.create(:user => users(:quentin), :mband => @mband, :instrument => instruments(:guitar))
      membership.accept!

      @mband.memberships << membership
      @mband.save
      assert_equal users(:quentin), @mband.leader
    end      

    assert_difference 'MbandMembership.count' do
      post :create, :mband_id => @mband.id, :user_id => users(:user_11).id, :instrument_id => instruments(:microphone).id
      post :create, :mband_id => @mband.id, :user_id => users(:quentin).id, :instrument_id => instruments(:saxophone).id
    end                

    assert_equal @mband.members_count, @mband.reload.members_count
  end
  
  def test_should_create_new_mband
    login_as :quentin
    assert_difference 'Mband.count' do      
      assert_difference 'MbandMembership.count', 2 do
        post :create, :mband_name => 'new mband', :leader_instrument_id => instruments(:drums).id,
                      :user_id => users(:user_11).id, :instrument_id => instruments(:guitar).id
      end
    end

    assert_equal 1, Mband.find_by_name('new mband').members_count
  end
  
  def test_should_accept
    login_as :quentin    

    quentin_band_memberships_count = mbands(:quentin_mband).memberships.count
    quentin_band_members_count = mbands(:quentin_mband).members.count
    cached_quentin_band_members_count = mbands(:quentin_mband).members_count

    assert_equal quentin_band_members_count, cached_quentin_band_members_count 
        
    assert_difference 'MbandMembership.count' do
      post :create, :mband_id => mbands(:quentin_mband).id, :user_id => users(:user_11).id, :instrument_id => instruments(:drums).id
    end

    assert_equal quentin_band_memberships_count + 1, mbands(:quentin_mband).reload.memberships.count
    assert_equal quentin_band_members_count, mbands(:quentin_mband).reload.members.count
    assert_equal cached_quentin_band_members_count, mbands(:quentin_mband).reload.members_count

    assert_equal mbands(:quentin_mband).reload.members_count, mbands(:quentin_mband).reload.members.count
    
    get :accept, :token => users(:user_11).mband_memberships.first.membership_token

    assert_equal quentin_band_members_count + 1, mbands(:quentin_mband).reload.members.count
    assert_equal cached_quentin_band_members_count + 1, mbands(:quentin_mband).reload.members_count

    assert_equal mbands(:quentin_mband).reload.members_count, mbands(:quentin_mband).reload.members.count
  end
  
end
