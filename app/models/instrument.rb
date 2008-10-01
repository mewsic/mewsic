# == Schema Information
# Schema version: 49
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

class Instrument < ActiveRecord::Base
  
  cattr_accessor :tracks_count
  
  has_many :tracks
  has_many :ideas, :class_name => 'Track', :conditions => ["tracks.idea = ?", true]
  belongs_to :category, :class_name => 'InstrumentCategory'

  validates_presence_of :description
  validates_uniqueness_of :description, :case_sensitive => false

  validates_presence_of :category_id
  validates_associated :category

  before_save :set_default_icon
  
  def self.find_by_ideas_count(options = {})
    find_by_sql(["
      SELECT I.*, I.id, COUNT(T.id) AS ideas_count
      FROM instruments I LEFT JOIN tracks T ON I.id = T.instrument_id
      WHERE T.idea = ? GROUP BY I.id ORDER BY ideas_count DESC LIMIT ?
     ", true, (options[:limit] || 5)])
  end

  def self.find_used
    find :all,:include => :tracks, :conditions => 'tracks.id IS NOT NULL', :order => 'instruments.description'
  end

  def find_ideas(limit = 5)
    self.ideas.find(:all, :order => 'rating_avg DESC', :limit => limit)
  end

  def find_paginated_ideas(options = {})
    self.ideas.paginate({:order => 'rating_avg DESC', :per_page => 10}.merge(options))
  end
  
  private

    def set_default_icon
      self.icon ||= "instruments/#{self.description.downcase.gsub(/\s/, '_')}.png"
    end

end
