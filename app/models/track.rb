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
require 'playable'

class Track < ActiveRecord::Base
  
  define_index do   
    has :bpm    
    has :idea
    has :key
    has :instrument_id
  end
  
  attr_accessor :mlab
  attr_accessor :tone
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :published_songs, :through => :mixes, :order => 'songs.created_at DESC', :conditions => ['songs.published = ?', true], :class_name => 'Song', :source => :song
  has_many :mixes, :dependent => :delete_all
  has_many :mlabs, :as => :mixable, :dependent => :delete_all

  belongs_to :parent_song, :class_name => 'Song', :foreign_key => 'song_id'
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'

  belongs_to :instrument

  validates_presence_of :title, :tonality, :seconds
  validates_associated :instrument, :parent_song, :owner
  validates_numericality_of :song_id, :greater_than => 0, :on => :create
  validates_numericality_of :instrument_id, :user_id, :greater_than => 0

  validates_each :filename do |model, attr, value|
    filename = model.absolute_filename :stream
    unless filename && File.file?(filename)
      model.errors.add(attr, "not found in media path (#{filename})")
    end
  end
  
  acts_as_rated :rating_range => 0..5 
  
  before_save :set_tonality_from_tone
  before_save :set_key_from_tone

  has_playable_stream

  # def self.search_paginated(q, options)
  #     options = {:per_page => 6, :page => 1}.merge(options)
  #     paginate(:per_page => options[:per_page], :page => options[:page], :include => [:mixes, :instrument, {:parent_song => {:user => :avatars}}], :conditions => [
  #       "(tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ?) AND tracks.idea = ?",
  #       *(Array.new(3).fill("%#{q}%") << false)
  #     ])
  #   end
  
  # def self.search_paginated_ideas(q, options)
  #   options = {:per_page => 6, :page => 1}.merge(options)
  #   paginate(:per_page => options[:per_page], :page => options[:page], :include => [:mixes, :instrument, {:parent_song => {:user => :avatars}}], :conditions => [
  #     "(tracks.title LIKE ? OR tracks.description LIKE ? OR instruments.description LIKE ?) AND tracks.idea = ?",
  #     *(Array.new(3).fill("%#{q}%") << true)
  #   ])
  # end
  
  def self.find_paginated_newest_ideas(options = {})
    options.reverse_update(:page => 1, :per_page => 3)
    paginate(options.merge(:conditions => ['tracks.idea = ? AND tracks.created_at > ?', true, 1.month.ago], :order => 'tracks.created_at DESC'))
  end

  def self.find_paginated_coolest_ideas(options = {})
    options.reverse_update(:page => 1, :per_page => 3)
    paginate(options.merge(:include => :songs, :conditions => ['tracks.idea = ?', true], :order => 'tracks.rating_avg DESC, songs.rating_avg DESC'))
  end

  def self.find_most_collaborated_ideas(options = {})
    self.find_by_sql(["
       SELECT T.*, COUNT(T.id) AS collaboration_count FROM tracks T, mixes M, songs S
       WHERE T.id = M.track_id AND S.id = M.song_id AND S.published = ? AND T.idea = ?
       GROUP BY T.id ORDER BY collaboration_count DESC, T.rating_avg DESC LIMIT ?
      ", true, true, (options[:limit] || 3)])
  end    

  def self.find_paginated_top_rated_ideas(options = {})
    options.reverse_update(:page => 1, :per_page => 3)
    paginate(options.merge(:select => 'tracks.*, COUNT(tracks.id) AS collaboration_count',
                           :joins => 'LEFT JOIN mixes M on M.track_id = tracks.id LEFT JOIN songs S on M.song_id = S.id = 1',
                           :conditions => ['tracks.idea = ? AND S.published = ?', true, true],
                           :group => 'tracks.id', :order => 'tracks.rating_avg DESC')
            ).each { |t| t.collaboration_count = t.collaboration_count.to_i }
  end

  def self.find_most_used(options = {})
    self.find(:all,
              options.merge(:select => 'tracks.*, COUNT(tracks.id) AS song_count',
                            :joins => 'LEFT JOIN mixes M ON M.track_id = tracks.id LEFT JOIN songs S ON M.song_id = S.id',
                            :conditions => ['tracks.idea = ? AND S.published = ?', false, true],
                            :group => 'tracks.id', :order => 'song_count DESC')
             ).each { |t| t.song_count = t.song_count.to_i }
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

  def destroyable?
    self.mixes.count.zero? || self.mixes.all? { |mix| !mix.song.published? rescue true } # XXX remove that rescue
  end

  def original_author
    self.parent_song ? self.parent_song.original_author : nil
  end
  
  #called by mlab.js 
  def genre_name
    (self.parent_song && self.parent_song.genre) ? self.parent_song.genre.name : nil
  end
  
private
  
  def set_tonality_from_tone
    self.tonality = self.tone unless self.tone.blank?
  end
  
  def set_key_from_tone
    if !self.tonality.blank? && (key = Myousica::TONES.index(self.tonality.upcase)) 
      self.key = key
    end
  end

end
