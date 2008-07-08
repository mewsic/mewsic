# == Schema Information
# Schema version: 41
#
# Table name: band_members
#
#  id             :integer(11)   not null, primary key
#  nickname       :string(20)    
#  instrument_id  :integer(11)   
#  user_id        :integer(11)   
#  created_at     :datetime      
#  updated_at     :datetime      
#  country        :string(45)    
#  linked_user_id :integer(11)   
#

class BandMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :instrument
  belongs_to :linked_user, :class_name => 'User' 
  has_many   :avatars, :as => :pictureable, :dependent => :destroy
  
  attr_accessible :nickname, :country, :instrument_id, :linked_user_id

  validates_presence_of :nickname, :if => Proc.new { |m| m.linked_user_id.blank? }
  validates_presence_of :linked_user_id, :if => Proc.new { |m| m.nickname.blank? }

  validates_presence_of :instrument_id, :user_id
  validates_associated :instrument, :user, :linked_user

  facade :nickname, :country, :avatars, :with => Proc.new { |m| m.linked_to_myousica_user? ? m.linked_user : m }

  def linked_to_myousica_user?
    !self.linked_user_id.blank?
  end

  def link_to(user)
    self.unlink!
    self.nickname = self.country = nil
    self.avatars_without_facade.each(&:destroy)
    self.linked_user_id = user.id
  end

  def unlink!
    self.linked_user_id = nil
  end

end
