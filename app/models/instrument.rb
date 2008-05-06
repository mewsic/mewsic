# == Schema Information
# Schema version: 14
#
# Table name: instruments
#
#  id          :integer(11)   not null, primary key
#  description :string(255)   
#  icon        :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Instrument < ActiveRecord::Base
  has_many :tracks
  
  before_save :set_default_icon

private

  def set_default_icon
    self.icon = 'instrument_drum.png'
  end
  
end
