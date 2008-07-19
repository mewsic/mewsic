# == Schema Information
# Schema version: 46
#
# Table name: instrument_categories
#
#  id          :integer(11)   not null, primary key
#  description :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class InstrumentCategory < ActiveRecord::Base
  has_many :instruments, :foreign_key => 'category_id'
  validates_presence_of :description
end
