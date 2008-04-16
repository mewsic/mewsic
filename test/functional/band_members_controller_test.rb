require File.dirname(__FILE__) + '/../test_helper'

class BandMembersControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  fixtures :users

  def test_create_band_member
    # assert_routing "/users/#{users(:mikaband).id}/band_members",
    #   :controller => 'band_members', :action => 'index', :user_id => users(:mikaband).id.to_s
    # assert_difference 'BandMember.count' do
    #   post user_band_member_path, :user_id => users(:mikaband), :member => { :name => 'ivan' }
    # end
    #get user_members_path, :user_id => users(:mikaband), :member => { :name => 'ivan' }
  end
  
end
