# == Schema Information
# Schema version: 20090312174538
#
# Table name: songs
#
#  id             :integer(4)    not null, primary key
#  title          :string(60)    
#  author         :string(60)    
#  description    :text          
#  filename       :string(64)    
#  user_id        :integer(4)    
#  seconds        :integer(4)    default(0)
#  listened_times :integer(4)    default(0)
#  published      :boolean(1)    default(TRUE)
#  created_at     :datetime      
#  updated_at     :datetime      
#  rating_count   :integer(4)    
#  rating_total   :decimal(10, 2 
#  rating_avg     :decimal(10, 2 
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# The Song model is one of the most important models in MEWSIC. It serves as a song container
# and implements many finders used by different controllers.
#
# Tracks are associated via an <tt>has_many :through</tt> the <tt>Mix</tt> join model.
#
# Songs have associated tracks via direct foreign key, too (the <tt>song_id</tt> attribute in
# the Track model), named <tt>children_tracks</tt>, and associated to a Song when recording
# live or uploading streams via the multitrack app.
#
# The <tt>published</tt> attribute sets whether a Song has to be displayed on the site, because
# unpublished songs are scraps created automatically when a registered user enters the multitrack.
# When a project is saved and the song encoded and mixed down, the <tt>published</tt> attribute
# is set to <tt>true</tt> by the MultitrackController#update_song method.
#
# Songs are full-text indexed by Sphinx and can be rated, using the <tt>medlar_acts_as_rated</tt>
# plugin (https://stage.lime5.it/rdoc/mewsic/plugins/medlar_acts_as_rated).
#
# Each Song has also a playable MP3 stream, handled by the Playable module. The Song model is
# instrumented by calling Playable#has_playable_stream in the class context.
#
# == Associations
#
# * <b>has_many</b> <tt>mixes</tt>, deleted all upon destroy. [Mix]
# * <b>has_many</b> <tt>tracks</tt> <b>through</b> <tt>mixes</tt> [Track]
# * <b>has_many</b> <tt>children_tracks</tt> [Track]
# * <b>has_many</b> <tt>abuses</tt> [Abuse]
#
# * <b>belongs_to</b> an User
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>title</tt>, and <tt>seconds</tt> if the 
#   Song is <tt>published</tt>
# * <b>validates_associated</b> User if the Song is <tt>published</tt>
# * <b>validates_numericality_of</b> <tt>user_id</tt>, greater than 0 if the Song is <tt>published</tt>
#
# == Callbacks
#
# * <b>before_destroy</b> +check_for_children_tracks+
#
require 'numeric_to_runtime'
require 'playable'

class Song < ActiveRecord::Base

  define_index do
    indexes :title, :author, :description
    indexes user.country, :as => :country
    where 'published = 1'
    set_property :delta => true
  end
 
  attr_accessor :mlab

  belongs_to :user, :polymorphic => true

  has_many :mixes, :dependent => :delete_all
  has_many :tracks, :through => :mixes, :order => 'tracks.created_at DESC'  
  has_many :children_tracks, :class_name => 'Track'

  # This association is here only for the :dependent trigger
  has_many :mlabs, :as => :mixable, :dependent => :delete_all
  #has_many :abuses, :as => :abuseable, :dependent => :delete_all, :class_name => 'Abuse'
 
  validates_presence_of :title,               :if => Proc.new(&:published)
  validates_associated :user,                 :if => Proc.new(&:published) 
  validates_length_of :tracks, :minimum => 1, :if => Proc.new(&:published)

  acts_as_rated :rating_range => 0..5

  before_save :copy_author_information_from_user
  before_destroy :check_for_children_tracks

  has_playable_stream

  # Finds all published songs
  #
  named_scope :published, :conditions => {:published => true}
  named_scope :unpublished, :conditions => {:published => false}

  named_scope :with_tracks, :include => :tracks, :conditions => 'tracks.id IS NOT NULL'

  # Finds all published songs, ordering them by play count and rating average.
  #
  def self.find_best(options = {})
    published.find(:all, options.merge(:order => 'songs.listened_times DESC, songs.rating_avg DESC'))
  end
  
  # Finds all published songs, ordering them by creation time.
  #
  def self.find_newest(options = {})
    published.find(:all, options.merge(:order => 'songs.created_at DESC'))
  end

  # Paginates the published songs created in the last month, ordering them by creation time.
  # By default, the first of 7 elements pages is returned. All the <tt>paginate</tt> options
  # are overridable. See the <tt>will_paginate</tt> plugin documentation for details:
  # https://stage.lime5.it/rdoc/mewsic/plugins/will_paginate
  #
  def self.find_newest_paginated(options = {})
    published.paginate(options.reverse_merge(
             :conditions => ['songs.created_at > ?', 1.month.ago],
             :order => 'songs.created_at DESC',
             :per_page => 7,
             :page => 1))
  end
 
  # Returns an array of all instruments used into this song.
  #
  def instruments
    self.tracks.count('instrument', :include => :instrument, :group => 'instrument_id').map { |id, count| Instrument.find(id) }
  end    
  
  # Shorthand to create an unpublished Song. Used by MultitrackController#show, when an user
  # enters the multitrack. The unpublished Song instance serves to store user data while he
  # is working: because every editing control in the M-Lab is in-place, Song has to be created
  # in advance.
  #
  def self.create_unpublished!
    self.create! :published => false
  end


  # Finds most collaborated songs, using a MySQL-only query (sorry).
  #
  def self.find_most_collaborated(options = {})
    collaboration_count = options[:minimum] || 2
    songs = find_by_sql(["
      SELECT s.*, COUNT(DISTINCT m.song_id) -1 AS collaboration_count,
        GROUP_CONCAT(DISTINCT m.song_id ORDER BY m.song_id) AS signature
      FROM mixes m LEFT OUTER JOIN mixes t ON m.track_id = t.track_id
      LEFT OUTER JOIN songs s ON t.song_id = s.id
      LEFT OUTER JOIN songs x ON m.song_id = x.id
      WHERE s.published = ? AND x.published = ?
      GROUP BY s.id
      HAVING collaboration_count >= ?
      ORDER BY collaboration_count DESC, s.rating_avg DESC
    ", true, true, collaboration_count])

    signatures = []
    songs = songs.select { |song|
      next if signatures.include? song.signature
      signatures.push song.signature
    }
    songs = songs.slice(0, options[:limit].to_i) if options[:limit]

    return songs
  end
  
  # Returns mixable songs, that share at least one track with this one.
  #
  def mixables(options = {})
    track_ids = self.tracks.map(&:id)
    Song.find(:all, :include => :mixes,
              :conditions => ['mixes.track_id IN (?) AND mixes.song_id <> ?', track_ids, self.id])
  end
  
  # Checks whether the passed Song is a direct version of this one.
  #
  def is_mixable_with?(song)
    mixables.include?(song)
  end
  
  # Returns the mixables count for this song. The +find_most_collaborated+ method
  # precalculates this counter, in order to optimize frequent calls,  so this method
  # first checks whether a <tt>collaboration_count</tt> attribute is present, if not 
  # it queries the database for the +mixables+ array and returns its <tt>size</tt>.
  #
  def collaboration_count
    (attributes['collaboration_count'] || mixables.size).to_i
  end 

  # Increment the <tt>listened_times</tt> counter. Currently called by PlayersController#show.
  #
  def increment_listened_times
    increment(:listened_times)
  end

  # Returns the pretty-printed length of the current song. See Numeric#to_runtime for details
  # on the formatting.
  #
  def length
    seconds.to_runtime
  end

  # Prints the song title into the breadcrumb (see ApplicationController#breadcrumb for details).
  #
  def to_breadcrumb
    self.title
  end    

  # Checks whether this Song is rateable by the passed User. A Song is not rateable by its creator.
  #
  def rateable_by?(user)
    self.user_id != user.id
  end

  # Shorthand to set the <tt>published</tt> attribute to <tt>true</tt> and save the song afterwards.
  # It also sets the <tt>@new</tt> instance variable to true if this song is yet not published, in
  # order for the SongObserver to send out a notification of "new song published".
  #
  def publish!
    @new = true if !self.published?
    self.published = true
    self.save!
  end

  # Returns true if the song has just been created. See the +publish!+ method for details.
  #
  def new?
    @new
  end

  # Called by the cron runner, to clean up unpublished songs that have got no children
  # tracks and have been created more than one week ago.
  #
  def self.cleanup_unpublished
    songs = find_by_sql(['select songs.id from songs
      left outer join tracks on tracks.song_id = songs.id
      where songs.published = ? and songs.created_at < ?
      group by songs.id having count(tracks.id) = 0', false, 1.week.ago])

    delete_all ['id in (?)', songs.map(&:id)] unless songs.empty?
  end
  
  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.7
  end

  # Checks whether this song has got children tracks, and raises ActiveRecord::ReadOnlyRecord
  # if it has. Used as a barrier to make songs with children tracks undeletable.
  #
  def check_for_children_tracks
    raise ActiveRecord::ReadOnlyRecord if self.published? && self.children_tracks.count > 0
  end

  def copy_author_information_from_user
    self.author = self.user.login if self.author.blank?
  end
end
