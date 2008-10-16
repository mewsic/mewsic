# == Schema Information
#
# Table name: instrument_categories
#
#  id          :integer(11)   not null, primary key
#  description :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#
# == Description
#
# This super-simple model represents an instrument category.
#
# == Associations
#
# * <b>has_many</b> <tt>instruments</tt>, linked via the Instrument <tt>category_id</tt>
#   attribute.
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>description</tt>
#
class InstrumentCategory < ActiveRecord::Base
  has_many :instruments, :foreign_key => 'category_id'
  validates_presence_of :description
end
