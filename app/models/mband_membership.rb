# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
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
# == Description
#
# This model represents a membership of an User to an Mband. Memberships are initiated by the
# Mband leader, and must be accepted by the receiver before becoming active. The <tt>accepted_at</tt>
# attribute contains the accept time stamp.
#
# Every Mband member plays an instrument, whose id is stored in <tt>instrument_id</tt>.
#
# The <tt>membership_token</tt> is used when creating links sent out membership invitation messages.
#
# <tt>members_count</tt> is a manual counter cache, incremented in +accept!+ and decremented in the
# +decrement_mband_members_count+ <tt>after_destroy</tt> callback.
#
# == Associations
#
# * <b>belongs_to</b> <tt>mband</tt> [Mband]
# * <b>belongs_to</b> <tt>user</tt> [User]
# * <b>belongs_to</b> <tt>instrument</tt> [Instrument]
# 
# == Validations
#
# * <b>validates_presence_of</b> <tt>mband_id</tt>, <tt>user_id</tt> and <tt>instrument_id</tt>
# * <b>validates_associated</b> <tt>mband</tt>, <tt>user</tt> and <tt>instrument</tt>
#
# == Callbacks
#
# * <b>after_create</b> +set_leader+
# * <b>after_destroy</b> +decrement_mband_members_count+
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

  # Updates this membership setting <tt>accepted_at</tt> to the current time and
  # increments the <tt>members_count</tt> attribute.
  #
  def accept!
    self.accepted_at = Time.now
    self.save!
    Mband.increment_counter :members_count, self.mband.id
  end
  
private

  # Decrements the <tt>members_count</tt> counter, if this membership has been
  # already accepted.
  #
  def decrement_mband_members_count
    unless self.accepted_at.nil?
      Mband.decrement_counter :members_count, self.mband.id
    end
  end

  # Creates a random SHA1-hashed membership token
  #
  def create_membership_token
    self.membership_token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  # If this Mband has only one member, sets it as leader
  #
  def set_leader
    self.mband.update_attribute(:user_id, self.user_id) if self.mband.memberships.count == 1
  end
  
end
