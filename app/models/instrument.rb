# == Schema Information
# Schema version: 20090312174538
#
# Table name: instruments
#
#  id          :integer(4)    not null, primary key
#  description :string(255)   
#  icon        :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#  category_id :integer(4)    
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This model represents an instrument. Instruments cannot be managed neither via the site
# interface nor via the admin one, only via <tt>script/console</tt>.
#
# == Associations
#
# * <b>has_many</b> <tt>tracks</tt>: tracks played on this instrument
# * <b>belongs_to</b> <tt>category</tt>: InstrumentCategory of this instrument
#
# == Validations
#
# Validates presence of <tt>description</tt> and <tt>category_id</tt>, the uniqueness
# of the <tt>description</tt> (case insensitive) and the associated <tt>category</tt>.
#
# == Callbacks
#
# * <b>before_save</b> +set_default_icon+
#
class Instrument < ActiveRecord::Base

  has_many :tracks
  belongs_to :category, :class_name => 'InstrumentCategory'

  validates_presence_of :description
  validates_uniqueness_of :description, :case_sensitive => false

  validates_associated :category

  before_save :set_default_icon

  named_scope :by_name, :order => 'instruments.description'
  named_scope :played, :include => :tracks, :conditions => 'tracks.id IS NOT NULL'

  def to_s
    description
  end

  def code
    description.downcase.tr(' ', '_')
  end

private
  # Sets the default icon inferring it by the current instrument description. Instrument
  # icons are located in <tt>public/images/instruments</tt>.
  def set_default_icon
    self.icon ||= "instruments/#{self.description.downcase.gsub(/\s/, '_')}.png"
  end

end
