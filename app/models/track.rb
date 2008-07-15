# == Schema Information
# Schema version: 43
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
#  idea           :boolean(1)    not null
#  user_id        :integer(11)   
#

require 'numeric_to_runtime'

class Track < ActiveRecord::Base
  
  attr_accessor :mlab
  attr_accessor :tone
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :mixes, :dependent => :destroy
  has_many :mlabs, :as => :mixable
  
  belongs_to :parent_song, :class_name => 'Song', :foreign_key => 'song_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'

  belongs_to :instrument

  validates_presence_of :title, :tonality, :seconds, :instrument_id, :song_id, :user_id
  validates_associated :instrument, :parent_song, :owner
  
  acts_as_rated :rating_range => 0..5 
  
  before_save :set_tonality_from_tone  

  def self.search_paginated(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    paginate(:per_page => options[:per_page], :page => options[:page], :include => [:mixes, :instrument, {:parent_song => {:user => :avatars}}], :conditions => [
      "tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ? AND mixes.track_id IS NOT NULL",
      *(Array.new(3).fill("%#{q}%"))
    ])
  end
  
  def self.search_paginated_ideas(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    paginate(:per_page => options[:per_page], :page => options[:page], :include => [:mixes, :instrument, {:parent_song => {:user => :avatars}}], :conditions => [
      "tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ? AND mixes.track_id IS NULL",
      *(Array.new(3).fill("%#{q}%"))
    ])
  end
  
  def self.find_most_collaborated(limit = 3)
    self.find_by_sql(["
       SELECT T.*, COUNT(T.id) AS collaboration_count FROM tracks T, mixes M, songs S
       WHERE T.id = M.track_id AND S.id = M.song_id AND S.published = ?
       GROUP BY T.id ORDER BY collaboration_count DESC LIMIT ?
      ", true, limit])
  end    
  
  def self.find_most_used(options = {})
    self.find(:all, options.merge(:select => 'tracks.*, COUNT(mixes.track_id) AS song_count', :joins => 'LEFT JOIN mixes ON mixes.track_id = tracks.id LEFT JOIN songs ON mixes.song_id = songs.id AND songs.published = 1', :group => 'mixes.track_id', :order => 'song_count DESC')).each { |t| t.song_count = t.song_count.to_i }
  end
  
  def self.find_paginated_by_user(page, user)
    paginate :per_page => 7,
             :conditions => ["tracks.user_id = ?", user.id],
             :include => :instrument, 
             :order => "tracks.created_at DESC",
             :page => page
  end
  
  def self.find_paginated_by_mband(page, mband)
    paginate :per_page => 7,
             :conditions => ["tracks.user_id IN (?)", mband.members.map(&:id)],
             :include => :instrument,
             :order => "tracks.created_at DESC",
             :page => page
  end
  
  def length
    seconds.to_runtime
  end
  
  def user
    self.owner ? self.owner : parent_song.user
  end
  
  def user=(u)
    self.owner = u
  end
  
  def increment_listened_times
    update_attribute(:listened_times, listened_times + 1)
  end
  
  def rateable_by?(user)
    self.user_id != user.id
  end
  
private
  
  def set_tonality_from_tone
    self.tonality = self.tone unless self.tone.blank?
  end

end
