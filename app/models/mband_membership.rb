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
#  instrument_id    :integer(11)
#

class MbandMembership < ActiveRecord::Base
  
  before_create :create_membership_token

  belongs_to :mband
  belongs_to :user
  belongs_to :instrument

  validates_presence_of :mband_id, :user_id, :instrument_id
  validates_associated :mband, :user, :instrument
  
  attr_protected :accepted_at
  after_create :set_leader

  after_destroy :decrement_mband_members_count

  def accept!
    self.accepted_at = Time.now
    self.save!
    Mband.increment_counter :members_count, self.mband.id
  end
  
private

  def decrement_mband_members_count
    unless self.accepted_at.nil?
      Mband.decrement_counter :members_count, self.mband.id
    end
  end

  def create_membership_token
    self.membership_token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def set_leader
    self.mband.update_attribute(:user_id, self.user_id) if self.mband.memberships.count == 1
  end
  
end
