require File.dirname(__FILE__) + '/../test_helper'

class MbandMembershipsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper

  fixtures :users, :mbands, :instruments, :mband_memberships

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def teardown
    super
    ActionMailer::Base.deliveries = []
  end
  
  def test_should_create_new_mband_and_memberships
    login_as :quentin

    quentin_messages_count = users(:quentin).received_messages.count
    user_11_messages_count = users(:user_11).received_messages.count

    assert_difference 'Mband.count' do      
      assert_difference 'MbandMembership.count', 2 do
        post :create, :mband_name => 'new mband', :leader_instrument_id => instruments(:drums).id,
                      :user_id => users(:user_11).id, :instrument_id => instruments(:guitar).id
      end
    end

    mband = assigns(:mband)
    assert_not_nil mband
    assert mband.valid?

    assert_equal 1, mband.reload.members_count

    assert_equal quentin_messages_count, users(:quentin).received_messages.count
    assert_equal user_11_messages_count + 1, users(:user_11).received_messages.count
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
  
  def test_should_accept
    login_as :quentin    

    quentin_band_memberships_count = mbands(:quentin_mband).memberships.count
    quentin_band_members_count = mbands(:quentin_mband).members.count
    cached_quentin_band_members_count = mbands(:quentin_mband).members_count

    user_11_messages_count = users(:user_11).received_messages.count

    assert_equal quentin_band_members_count, cached_quentin_band_members_count 
        
    assert_difference 'MbandMembership.count' do
      post :create, :mband_id => mbands(:quentin_mband).id, :user_id => users(:user_11).id, :instrument_id => instruments(:drums).id
    end

    assert_equal user_11_messages_count + 1, users(:user_11).received_messages.count
    assert_equal 1, ActionMailer::Base.deliveries.size

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
