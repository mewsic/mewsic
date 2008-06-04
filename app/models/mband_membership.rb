# == Schema Information
# Schema version: 26
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

  validates_presence_of :mband_id, :user_id
  validates_associated :mband, :user
  
  attr_protected :accepted_at
  after_create :set_leader
  
private

  def create_membership_token
    self.membership_token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def set_leader
    self.mband.update_attribute(:user_id, self.user_id) if self.mband.mband_memberships.count == 1
  end
  
end
