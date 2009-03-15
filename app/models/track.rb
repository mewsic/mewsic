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
require 'statuses'

class Track < ActiveRecord::Base
  
  attr_accessor :mlab
  
  has_many :mixes, :conditions => 'deleted = 0'
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'

  has_many :mlabs, :as => :mixable
  #has_many :abuses, :as => :abuseable, :class_name => 'Abuse'

  belongs_to :user
  belongs_to :instrument

  validates_presence_of :title, :seconds
  validates_associated :instrument, :user
  validates_numericality_of :instrument_id, :user_id, :greater_than => 0

  validates_each :filename do |model, attr, value|
    filename = model.absolute_filename :stream
    unless filename && File.file?(filename)
      model.errors.add(attr, "not found in media path (#{filename})")
    end
  end

  before_destroy :check_if_deleted
  before_destroy :destroy_mixes
  
  acts_as_rated :rating_range => 0..5 
  
  has_playable_stream

  has_multiple_statuses :public => 1, :private => 2, :deleted => -1

  # Track statuses
  named_scope :public, :conditions => {:status => statuses.public}
  named_scope :private, :conditions => {:status => statuses.private}

  define_index do
    has :instrument_id
    indexes :title, :description
    indexes user.country, :as => :country
    indexes instrument.description, :as => :instrument
    where "status = #{statuses.public}"
    set_property :delta => true
  end

  def accessible_by?(user)
    (self.status == :private && self.user == user) || self.status == :public
  end

  # Finds most collaborated tracks and sets a virtual <tt>song_count</tt> attribute that yields
  # the song count for each track.
  #
  def self.find_most_used(options = {})
    limit = "LIMIT #{options[:limit]}" if options[:limit]
    self.find_by_sql(["SELECT tracks.*, COUNT(tracks.id) AS song_count FROM tracks LEFT JOIN mixes M ON M.track_id = tracks.id LEFT JOIN songs S ON M.song_id = S.id WHERE M.deleted = 0 AND S.status = ? GROUP BY tracks.id ORDER BY song_count DESC #{limit}", Song.statuses.public]).each { |t| t.song_count = t.song_count.to_i }
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

  # Set the :deleted status rather than deleting the record,
  # and delete all the mixes and mlabs linked to this track.
  def delete
    Track.transaction do
      raise ActiveRecord::ReadOnlyRecord unless deletable?
      self.status = :deleted
      self.save!
      self.mixes.destroy_all
      self.mlabs.destroy_all
    end
  end

  private
  # Deletable policy.
  # A track is not deletable if it is mixed into other published songs (either public or private)
  #
  def deletable?
    self.mixes.count.zero? || !self.mixes.any? { |mix| mix.song.published? }
  end

  # A track can be destroyed only if it is already deleted.
  def check_if_deleted
    raise ActiveRecord::ReadOnlyRecord unless deleted?
  end

  def destroy_mixes
    Mix.delete_all ['track_id = ?', self.id]
  end

end
