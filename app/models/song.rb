# == Schema Information
# Schema version: 15
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
#  bpm             :integer(11)   
#  seconds         :integer(11)   default(0)
#  listened_times  :integer(11)   default(0)
#  published       :boolean(1)    default(TRUE)
#  created_at      :datetime      
#  updated_at      :datetime      
#  rating_count    :integer(11)   
#  rating_total    :decimal(10, 2 
#  rating_avg      :decimal(10, 2 
#

class Song < ActiveRecord::Base
  
  attr_accessor :mlab
  
  has_many :tracks, :through => :mixes, :order => 'created_at DESC'
  has_many :mixes
  has_many :children_tracks, :class_name => 'Track'
  has_many :mlabs, :as => :mixable


  belongs_to :genre
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5
  
  def self.find_published(options = {})
    self.find(:all, :conditions => ["songs.published = ?", true])
  end      
  
  # TODO: STUB fino ai criteri di best
  def self.find_best(options = {})
    self.find(:all, options)
  end
  
  def self.find_newest(options = {})
    options.merge!({:order => 'songs.created_at DESC'})
    options[:conditions] = ["songs.published = ?", true]
    self.find(:all, options)
  end
  
  def self.find_paginated_by_genre(page, genre_id)
    paginate :per_page => 20, 
             :conditions => ["songs.published = ? AND genre_id = ?", true, genre_id], 
             :order => "songs.title ASC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  # TODO: Unire i due metodi in uno unico 
  def self.find_paginated_by_user(page, user_id)
    paginate :per_page => 3, 
             :conditions => ["songs.published = ? AND user_id = ?", true, user_id], 
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
    Song.find(:all, :include => :tracks, :limit => 2, :conditions => ["songs.published = ? AND songs.id != ?", true, self.id])
  end
  
  # STUB
  def indirect_siblings
    Song.find(:all, :include => :tracks, :limit => 2, :conditions => ["songs.published = ? AND songs.id != ?", true, self.id])
  end
  
  def siblings_count
    120
  end 
  
  def update_children_tracks_count
    self.children_tracks_count = self.children_tracks.count(true)
    save
    if self.children_tracks.count == 1
      puts "#{self.reload.children_tracks_count.inspect} => #{self.title}"
    end
  end
  
  def increment_listened_times
    update_attribute(:listened_times, listened_times + 1)
  end
  
  def length
    hours,   remainig = self.seconds.divmod(3600)
    minutes, remainig = remainig.divmod(60)
    seconds = remainig    
    "#{zerofill(hours, 2)}:#{zerofill(minutes, 2)}:#{zerofill(seconds, 2)}"
  end

private

  def zerofill(number, length)
    string = number.to_s
    (length - string.size).times{ string = "0#{string}"}
    string
  end  
end
