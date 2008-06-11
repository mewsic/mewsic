# == Schema Information
# Schema version: 26
#
# Table name: band_members
#
#  id            :integer(11)   not null, primary key
#  name          :string(255)   
#  instrument_id :integer(11)   
#  user_id       :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#

class BandMember < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :instrument
  has_many    :avatars, :as => :pictureable
  
  attr_accessible :name, :instrument_id

  validates_presence_of :name, :instrument_id, :user_id
  validates_associated :instrument, :user
end
