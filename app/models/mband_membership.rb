# == Schema Information
# Schema version: 21
#
# Table name: mband_memberships
#
#  id               :integer(11)   not null, primary key
#  mband_id         :integer(11)   
#  user_id          :integer(11)   
#  membership_token :string(255)   
#  accepted_at      :datetime      
#  created_at       :datetime      
#  updated_at       :datetime      
#

class MbandMembership < ActiveRecord::Base
  
  before_create :create_membership_token
  belongs_to :mband
  belongs_to :user
  
private

  def create_membership_token
    self.membership_token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
end
