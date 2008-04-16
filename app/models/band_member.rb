# == Schema Information
# Schema version: 14
#
# Table name: band_members
#
#  id            :integer(11)   not null, primary key
#  name          :string(255)   
#  instrument_id :integer(11)   
#  band_id       :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#

class BandMember < ActiveRecord::Base
  belongs_to :band
  belongs_to :instrument
  
  before_save :set_default_instrument
  
  attr_accessible :name, :instrument
  
protected

  def set_default_instrument
    self.instrument = Instrument.find_by_description('Guitar') if self.instrument.nil?
  end
  
end
