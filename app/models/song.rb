# == Schema Information
# Schema version: 12
#
# Table name: songs
#
#  id              :integer(11)   not null, primary key
#  title           :string(255)   
#  original_author :string(255)   
#  description     :string(255)   
#  tone            :string(255)   
#  filename        :string(255)   
#  user_id         :integer(11)   
#  genre_id        :integer(11)   
#  listened_times  :integer(11)   
#  bpm             :integer(11)   
#  created_at      :datetime      
#  updated_at      :datetime      
#  rating_count    :integer(11)   
#  rating_total    :decimal(10, 2 
#  rating_avg      :decimal(10, 2 
#

class Song < ActiveRecord::Base
  
  attr_accessor :mlab
  
  has_many :tracks, :through => :mixes
  has_many :mixes
  has_many :children_tracks, :class_name => 'Track'
  has_many :mlabs, :as => :mixable


  belongs_to :genre
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5
  
  # TODO: STUB fino ai criteri di best
  def self.find_best(options = {})
    self.find(:all, options)
  end
  
  def self.find_newest(options = {})
    options.merge!({:order => 'songs.created_at DESC'})
    self.find(:all, options)
  end
  
  def self.find_paginated_by_genre(page, genre_id)
    paginate :per_page => 20, 
             :conditions => ["genre_id = ?", genre_id], 
             :order => "songs.title ASC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  # TODO: Unire i due metodi in uno unico 
  def self.find_paginated_by_user(page, user_id)
    paginate :per_page => 3, 
             :conditions => ["user_id = ?", user_id], 
             :order => "songs.title ASC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
    
  # STUB: sino all'implementazione degli strumenti
  def instruments
    ['sassofono', 'batteria', 'anoleso']
  end
  
  # STUB
  def direct_siblings
    Song.find(:all, :include => :tracks, :limit => 2, :conditions => ["songs.id != ?", self.id])
  end
  
  # STUB
  def indirect_siblings
    Song.find(:all, :include => :tracks, :limit => 2, :conditions => ["songs.id != ?", self.id])
  end
  
end
