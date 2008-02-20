# == Schema Information
# Schema version: 11
#
# Table name: tracks
#
#  id            :integer(11)   not null, primary key
#  title         :string(255)   
#  filename      :string(255)   
#  description   :string(255)   
#  song_id       :integer(11)   
#  instrument_id :integer(11)   
#  bpm           :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#  rating_count  :integer(11)   
#  rating_total  :decimal(10, 2 
#  rating_avg    :decimal(10, 2 
#

class Track < ActiveRecord::Base
  has_many :songs, :through => :mixes
  has_many :mixes
  
  belongs_to :parent_song, :class_name => 'Song', :include => :user, :foreign_key => 'song_id'
  belongs_to :instrument
  
  acts_as_rated :rating_range => 0..5  
  
  # FIXME: Per motivi di performance dovremmo tirare dentro anche gli users e la parent_song
  def self.find_most_used(options = {})
    Mix.count options.merge({:include => [{:track => :instrument}], :group => :track, :order => 'count_all DESC'}) 
  end
  
  def self.find_paginated_by_user(page, user_id)
    paginate :per_page => 7,
             :conditions => ["songs.user_id = ?", user_id],
             :include => [{:songs => :user}], 
             :order => "tracks.title ASC",
             :page => page
  end
  
end
