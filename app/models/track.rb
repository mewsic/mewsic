# == Schema Information
# Schema version: 49
#
# Table name: tracks
#
#  id                     :integer(11)   not null, primary key
#  title                  :string(255)   
#  filename               :string(255)   
#  description            :string(255)   
#  tonality               :string(255)   default("C")
#  song_id                :integer(11)   
#  instrument_id          :integer(11)   
#  listened_times         :integer(11)   default(0)
#  seconds                :integer(11)   default(0)
#  bpm                    :integer(11)   
#  created_at             :datetime      
#  updated_at             :datetime      
#  rating_count           :integer(11)   
#  rating_total           :decimal(10, 2 
#  rating_avg             :decimal(10, 2 
#  idea                   :boolean(1)    not null
#  user_id                :integer(11)   
#  instrument_description :string(255)   
#

require 'numeric_to_runtime'

class Track < ActiveRecord::Base
  
  acts_as_sphinx
  extend SphinxWillPagination
  
  attr_accessor :mlab
  attr_accessor :tone
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :mixes, :dependent => :destroy
  has_many :mlabs, :as => :mixable
  
  belongs_to :parent_song, :class_name => 'Song', :foreign_key => 'song_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'

  belongs_to :instrument

  validates_presence_of :title, :tonality, :seconds, :instrument_id, :song_id, :user_id, :filename
  validates_associated :instrument, :parent_song, :owner
  validates_each :instrument_id, :song_id, :user_id do |model, attr, value|
    model.errors.add(attr, "invalid #{attr}") if value.to_i.zero?
  end

  validates_each :filename do |model, attr, value|
    unless File.file?(File.join(APPLICATION[:media_path], value.to_s))
      model.errors.add(attr, 'file not found')
    end
  end
  
  acts_as_rated :rating_range => 0..5 
  
  before_save :set_tonality_from_tone  
  before_validation :clean_up_filename

  after_destroy :delete_sound_file

  def self.search(q, options = {})
    find(:all, {:include => :instrument, :conditions => [
      "tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ?",
      *(Array.new(3).fill("%#{q}%"))
    ]}.merge(options))
  end

  def self.search_paginated(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    paginate(:per_page => options[:per_page], :page => options[:page], :include => [:mixes, :instrument, {:parent_song => {:user => :avatars}}], :conditions => [
      "(tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ?) AND tracks.idea = ?",
      *(Array.new(3).fill("%#{q}%") << false)
    ])
  end
  
  def self.search_paginated_ideas(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    paginate(:per_page => options[:per_page], :page => options[:page], :include => [:mixes, :instrument, {:parent_song => {:user => :avatars}}], :conditions => [
      "(tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ?) AND tracks.idea = ?",
      *(Array.new(3).fill("%#{q}%") << true)
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
    user.tracks.paginate(:page => page, :per_page => 7, :include => :instrument, :order => "tracks.created_at DESC")
  end

  def self.find_paginated_ideas_by_user(page, user)
    user.tracks.paginate(:page => page, :per_page => 7, :include => :instrument, :conditions => ['tracks.idea = ?', true], :order => "tracks.created_at DESC")
  end
  
  def self.find_paginated_by_mband(page, mband)
    paginate(:page => page, :per_page => 7, :include => :instrument, :conditions => ["tracks.user_id IN (?)", mband.members.map(&:id)], :order => "tracks.created_at DESC")
  end

  def self.find_paginated_ideas_by_mband(page, mband)
    paginate(:page => page, :per_page => 7, :include => :instrument, :conditions => ["tracks.user_id IN (?) AND tracks.idea = ?", mband.members.map(&:id), true], :order => "tracks.created_at DESC")
  end

  def self.find_paginated_newest_ideas(page)
    paginate(:page => page, :per_page => 3, :conditions => ['tracks.idea = ? AND tracks.created_at > ?', true, 1.month.ago], :order => 'tracks.created_at DESC')
  end

  def self.find_paginated_coolest_ideas(page)
    paginate(:page => page, :per_page => 3, :include => :songs, :conditions => ['tracks.idea = ?', true], :order => 'tracks.rating_avg DESC, songs.rating_avg DESC')
  end

  def self.find_paginated_top_rated_ideas(page)
    paginate(:page => page, :per_page => 3, :conditions => ['tracks.idea = ?', true], :order => 'tracks.rating_avg DESC')
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

  def original_author
    self.parent_song ? self.parent_song.original_author : nil
  end
  
  #called by mlab.js 
  def genre_name
    (self.parent_song && self.parent_song.genre) ? self.parent_song.genre.name : nil
  end
  
  def public_filename(type = :stream)
    filename = self.filename.dup
    filename.sub! /\.mp3$/, '.png' if type == :waveform

    APPLICATION[:audio_url] + '/' + filename
  end
  
private
  
  def set_tonality_from_tone
    self.tonality = self.tone unless self.tone.blank?
  end

  def delete_sound_file
    File.unlink File.join(APPLICATION[:media_path], self.filename)
  end

  def clean_up_filename
    self.filename = File.basename(self.filename) if self.filename
  end

end
