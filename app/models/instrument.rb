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
# == Schema Information
#
# Table name: instruments
#
#  id          :integer(11)   not null, primary key
#  description :string(255)   
#  icon        :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#  category_id :integer(11)   
#
# == Description
#
# This model represents an instrument. Instruments cannot be managed neither via the site
# interface nor via the admin one, only via <tt>script/console</tt>.
#
# == Associations
#
# * <b>has_many</b> <tt>tracks</tt>: tracks played on this instrument
# * <b>has_many</b> <tt>ideas</tt>: tracks marked as idea played on this instrument
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
  has_many :ideas, :class_name => 'Track', :conditions => ["tracks.idea = ?", true]
  belongs_to :category, :class_name => 'InstrumentCategory'

  validates_presence_of :description
  validates_uniqueness_of :description, :case_sensitive => false

  validates_presence_of :category_id
  validates_associated :category

  before_save :set_default_icon

  # Finds instruments that have got some associated idea tracks, ordering it by the
  # tracks count. The only valid <tt>option</tt> is <tt>:limit</tt>, that indicates
  # how many records to fetch.
  def self.find_by_ideas_count(options = {})
    find_by_sql(["
      SELECT I.*, I.id, COUNT(T.id) AS ideas_count
      FROM instruments I LEFT JOIN tracks T ON I.id = T.instrument_id
      WHERE T.idea = ? GROUP BY I.id ORDER BY ideas_count DESC LIMIT ?
     ", true, (options[:limit] || 5)])
  end

  # Finds all instruments that have got at least one track associated, ordering 'em
  # by instrument description.
  def self.find_used
    find :all,:include => :tracks, :conditions => 'tracks.id IS NOT NULL', :order => 'instruments.description'
  end

  # Finds ideas associated to this instrument, ordering 'em by rating average. The
  # <tt>limit</tt> option indicates how many records to fetch.
  def find_ideas(limit = 5)
    self.ideas.find(:all, :order => 'rating_avg DESC', :limit => limit)
  end

  # Paginates ideas sorting 'em by rating average. 10 items per page. The <tt>options</tt>
  # parameter hash can override any <tt>paginate</tt> option.
  def find_paginated_ideas(options = {})
    self.ideas.paginate({:order => 'rating_avg DESC', :per_page => 10}.merge(options))
  end

  private

    # Sets the default icon inferring it by the current instrument description. Instrument
    # icons are located in <tt>public/images/instruments</tt>.
    def set_default_icon
      self.icon ||= "instruments/#{self.description.downcase.gsub(/\s/, '_')}.png"
    end

end
