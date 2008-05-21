require File.dirname(__FILE__) + '/../test_helper'

class MbandMembershipsControllerTest < ActionController::TestCase
  
  fixtures :all
  include AuthenticatedTestHelper

  def test_should_create    
    login_as :quentin
    assert_difference 'Mband.count' do
      @mband = Mband.create(:name => 'my mband')
      membership = MbandMembership.create(:user => users(:quentin), :mband => @mband)
      membership.update_attribute(:accepted_at, Time.now)      
      @mband.mband_memberships << membership
      @mband.save
      assert_equal users(:quentin), @mband.leader
    end      

    assert_difference 'MbandMembership.count' do
      post :create, :mband_id => @mband.id, :user_id => users(:user_11).id
      post :create, :mband_id => @mband.id, :user_id => users(:quentin).id
    end                
  end
  
  def test_should_create_new_mband
    login_as :quentin
    #assert_difference 'Mband.count' do      
      assert_difference 'MbandMembership.count' do
        post :create, :mband_id => 0, :mband_name => 'new mband', :user_id => users(:user_11).id
      end
    #end
  end
  
  def test_should_accept
    login_as :quentin    
    quentin_band_memberships_count = mbands(:quentin_mband).mband_memberships.count
    quentin_band_members_count = mbands(:quentin_mband).members.count
        
    assert_difference 'MbandMembership.count' do
      post :create, :mband_id => mbands(:quentin_mband).id, :user_id => users(:user_11).id
    end    
    assert_equal quentin_band_memberships_count + 1, mbands(:quentin_mband).reload.mband_memberships.count
    assert_equal quentin_band_members_count, mbands(:quentin_mband).reload.members.count
    
    get :accept, :token => users(:user_11).mband_memberships.first.membership_token    
    assert_equal quentin_band_members_count + 1, mbands(:quentin_mband).reload.members.count
    
  end
  
end
