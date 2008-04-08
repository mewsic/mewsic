# == Schema Information
# Schema version: 13
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
end
