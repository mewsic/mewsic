# == Schema Information
# Schema version: 46
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
  
  def self.find_by_ideas_count(limit = 5)   
   self.find_by_sql(["
     SELECT I.*, I.id, COUNT(T.id) AS ideas_count
     FROM instruments I LEFT JOIN tracks T ON I.id = T.instrument_id
     WHERE T.idea = ? GROUP BY I.id ORDER BY ideas_count DESC LIMIT ?
    ", true, limit])
  end
  
  def find_ideas
    self.tracks.find(:all, :conditions => ["tracks.idea = ?", true], :limit => 5)
  end
  
  private

    def set_default_icon
      self.icon ||= "instruments/#{self.description.downcase.gsub(/\s/, '_')}.png"
    end

end
