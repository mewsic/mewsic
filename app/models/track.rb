# == Schema Information
# Schema version: 20090311224230
#
# Table name: tracks
#
#  id                     :integer(4)    not null, primary key
#  title                  :string(60)    
#  filename               :string(64)    
#  song_id                :integer(4)    
#  instrument_id          :integer(4)    
#  listened_times         :integer(4)    default(0)
#  seconds                :integer(4)    default(0)
#  created_at             :datetime      
#  updated_at             :datetime      
#  rating_count           :integer(4)    
#  rating_total           :decimal(10, 2 
#  rating_avg             :decimal(10, 2 
#  user_id                :integer(4)    
#

require 'numeric_to_runtime'
require 'playable'

class Track < ActiveRecord::Base
  
  #define_index do
  #  has :instrument_id
  #  indexes :title, :description
  #  indexes user.country, :as => :country
  #  indexes instrument.description, :as => :instrument
  #end
  
  attr_accessor :mlab
  
  has_many :songs, :through => :mixes, :order => 'songs.created_at DESC'
  has_many :published_songs, :through => :mixes, :order => 'songs.created_at DESC', :conditions => ['songs.published = ?', true], :class_name => 'Song', :source => :song

  has_many :mixes, :dependent => :delete_all
  has_many :mlabs, :as => :mixable, :dependent => :delete_all
  #has_many :abuses, :as => :abuseable, :dependent => :delete_all, :class_name => 'Abuse'

  belongs_to :parent_song, :class_name => 'Song'
  belongs_to :user
  belongs_to :instrument

  validates_presence_of :title, :seconds
  validates_associated :instrument, :parent_song
  validates_numericality_of :song_id, :greater_than => 0, :on => :create
  validates_numericality_of :instrument_id, :user_id, :greater_than => 0

  validates_each :filename do |model, attr, value|
    filename = model.absolute_filename :stream
    unless filename && File.file?(filename)
      model.errors.add(attr, "not found in media path (#{filename})")
    end
  end
  
  acts_as_rated :rating_range => 0..5 
  
  has_playable_stream

  def self.find_most_used(options = {})
    self.find(:all,
              options.merge(:select => 'tracks.*, COUNT(tracks.id) AS song_count',
                            :joins => 'LEFT JOIN mixes M ON M.track_id = tracks.id LEFT JOIN songs S ON M.song_id = S.id',
                            :conditions => ['S.published = ?', true],
                            :group => 'tracks.id', :order => 'song_count DESC')
             ).each { |t| t.song_count = t.song_count.to_i }
  end
  
  def self.find_paginated_by_user(page, user)
    user.tracks.paginate(:page => page, :per_page => 7, :include => :instrument, :order => "tracks.created_at DESC")
  end

  def self.find_paginated_by_mband(page, mband)
    paginate(:page => page, :per_page => 7, :include => :instrument, :conditions => ["tracks.user_id IN (?)", mband.members.map(&:id)], :order => "tracks.created_at DESC")
  end

  def length
    seconds.to_runtime
  end
  
  def increment_listened_times
    # increment(:listened_times) XXX
    update_attribute(:listened_times, listened_times + 1)
  end
  
  def rateable_by?(user)
    self.user_id != user.id
  end

  def destroyable?
    self.mixes.count.zero? || self.mixes.all? { |mix| !mix.song.published? rescue true } # XXX remove that rescue
  end

end
