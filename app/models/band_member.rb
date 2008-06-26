# == Schema Information
# Schema version: 35
#
# Table name: band_members
#
#  id            :integer(11)   not null, primary key
#  name          :string(20)    
#  instrument_id :integer(11)   
#  user_id       :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#  country       :string(45)
#

class BandMember < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :instrument
  has_many    :avatars, :as => :pictureable
  
  attr_accessible :name, :country, :instrument_id

  validates_presence_of :name, :instrument_id, :user_id
  validates_associated :instrument, :user
end
