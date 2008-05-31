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
  attr_accessor :tone
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :mixes
  has_many :mlabs, :as => :mixable
  
  belongs_to :parent_song, :class_name => 'Song', :include => :user, :foreign_key => 'song_id'
  belongs_to :instrument
  
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
  
  def self.find_orphans(options = {})
    options.merge!({:include => [:mixes, :parent_song], :conditions => ["mixes.track_id is null AND tracks.song_id IS NOT NULL AND songs.published = ?", true] })
    self.find(:all, options)
  end
  
  def self.find_most_used(options = {})
    res = Mix.count options.merge({:include => [{:track => [{:parent_song => :user}, :instrument]}], :conditions => ["songs.published = ?", true],  :group => :track, :order => 'count_all DESC'}) 
    # FIXME
    res.find_all{|t,c| [t,c] if t}
  end
  
  def self.find_paginated_by_user(page, user)
    paginate :per_page => 7,
             :conditions => ["songs.user_id = ?", user.id],
             :include => [:instrument, {:parent_song => :user}], 
             :order => "tracks.title ASC",
             :page => page
  end
  
  def self.find_paginated_by_mband(page, mband)
    paginate :per_page => 7,
             :conditions => ["songs.user_id IN (?)", mband.members.collect{|m| m.id}.join(',')],
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
  
  def set_tonality_from_tone
    self.tonality = self.tone unless self.tone.blank?
  end
  
  def zerofill(number, length)
    string = number.to_s
    (length - string.size).times{ string = "0#{string}"}
    string
  end
  
end
