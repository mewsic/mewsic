# == Schema Information
# Schema version: 21
#
# Table name: tracks
#
#  id             :integer(11)   not null, primary key
#  title          :string(255)   
#  filename       :string(255)   
#  description    :string(255)   
#  tonality       :string(255)   default("C")
#  song_id        :integer(11)   
#  instrument_id  :integer(11)   
#  listened_times :integer(11)   default(0)
#  seconds        :integer(11)   default(0)
#  bpm            :integer(11)   
#  created_at     :datetime      
#  updated_at     :datetime      
#  rating_count   :integer(11)   
#  rating_total   :decimal(10, 2 
#  rating_avg     :decimal(10, 2 
#

class Track < ActiveRecord::Base
  
  attr_accessor :mlab
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :mixes
  has_many :mlabs, :as => :mixable
  
  belongs_to :parent_song, :class_name => 'Song', :include => :user, :foreign_key => 'song_id'
  belongs_to :instrument
  
  acts_as_rated :rating_range => 0..5 
  
  def self.find_orphans(options = {})
    options.merge!({ :include => :mixes, :conditions => 'mixes.track_id is null' })
    self.find(:all, options)
  end
  
  # FIXME: Per motivi di performance dovremmo tirare dentro anche gli users e la parent_song
  def self.find_most_used(options = {})
    Mix.count options.merge({:include => [{:track => :instrument}], :group => :track, :order => 'count_all DESC'}) 
  end
  
  def self.find_paginated_by_user(page, user_id)
    paginate :per_page => 7,
             :conditions => ["songs.user_id = ?", user_id],
             :include => [:instrument, {:parent_song => :user}], 
             :order => "tracks.title ASC",
             :page => page
  end
  
  def length
    hours,   remainig = self.seconds.divmod(3600)
    minutes, remainig = remainig.divmod(60)
    seconds = remainig    
    "#{zerofill(hours, 2)}:#{zerofill(minutes, 2)}:#{zerofill(seconds, 2)}"
  end
  
  def user
    @user ||= parent_song.user
  end
  
  def increment_listened_times
    update_attribute(:listened_times, listened_times + 1)
  end
  
private
  
  def zerofill(number, length)
    string = number.to_s
    (length - string.size).times{ string = "0#{string}"}
    string
  end
  
end
