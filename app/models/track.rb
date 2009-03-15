# == Schema Information
# Schema version: 20090312174538
#
# Table name: tracks
#
#  id             :integer(4)    not null, primary key
#  title          :string(60)    
#  filename       :string(64)    
#  description    :text          
#  song_id        :integer(4)    
#  instrument_id  :integer(4)    
#  listened_times :integer(4)    default(0)
#  seconds        :integer(4)    default(0)
#  created_at     :datetime      
#  updated_at     :datetime      
#  rating_count   :integer(4)    
#  rating_total   :decimal(10, 2 
#  rating_avg     :decimal(10, 2 
#  user_id        :integer(4)    
#  author         :string(60)    
#

require 'numeric_to_runtime'
require 'playable'

class Track < ActiveRecord::Base
  
  define_index do
    has :instrument_id
    indexes :title, :description
    indexes user.country, :as => :country
    indexes instrument.description, :as => :instrument
    where 'published = 1'
    set_property :delta => true
  end
  
  attr_accessor :mlab
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :mixes, :dependent => :delete_all
  has_many :mlabs, :as => :mixable, :dependent => :delete_all
  #has_many :abuses, :as => :abuseable, :dependent => :delete_all, :class_name => 'Abuse'

  belongs_to :user
  belongs_to :instrument

  validates_presence_of :title, :seconds
  validates_associated :instrument
  validates_numericality_of :instrument_id, :user_id, :greater_than => 0

  validates_each :filename do |model, attr, value|
    filename = model.absolute_filename :stream
    unless filename && File.file?(filename)
      model.errors.add(attr, "not found in media path (#{filename})")
    end
  end
  
  acts_as_rated :rating_range => 0..5 
  
  has_playable_stream

  named_scope :published, :conditions => {:published => true}
  named_scope :unpublished, :conditions => {:published => false}

  # Finds most collaborated tracks and sets a virtual <tt>song_count</tt> attribute that yields
  # the song count for each track.
  #
  def self.find_most_used(options = {})
    limit = "LIMIT #{options[:limit]}" if options[:limit]
    self.find_by_sql(["SELECT tracks.*, COUNT(tracks.id) AS song_count FROM tracks LEFT JOIN mixes M ON M.track_id = tracks.id LEFT JOIN songs S ON M.song_id = S.id WHERE S.published = ? GROUP BY tracks.id ORDER BY song_count DESC #{limit}", true]).each { |t| t.song_count = t.song_count.to_i }
  end
  
  def length
    seconds.to_runtime
  end
  
  def increment_listened_times
    increment(:listened_times)
  end
  
  # An user cannot rate its own tracks
  #
  def rateable_by?(user)
    self.user.rateable_by?(user)
  end

  # Destroyable policy.
  # A track is not destroyable if it is mixed into other published songs.
  #
  def destroyable?
    self.mixes.count.zero? || self.mixes.all? { |mix| !mix.song.published? rescue true } # XXX remove that rescue
  end

end
