# == Schema Information
# Schema version: 20090312174538
#
# Table name: instrument_categories
#
#  id          :integer(4)    not null, primary key
#  description :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
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
# Validates presence of the <tt>description</tt>.
#
class InstrumentCategory < ActiveRecord::Base
  has_many :instruments, :foreign_key => 'category_id'
  validates_presence_of :description

  named_scope :by_name, :order => 'instrument_category.description'

  def to_s
    description
  end
end
