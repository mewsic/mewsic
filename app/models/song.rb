# == Schema Information
# Schema version: 20090311224230
#
# Table name: songs
#
#  id              :integer(4)    not null, primary key
#  title           :string(60)    
#  original_author :string(60)    
#  description     :string(255)   
#  tone            :string(2)     
#  filename        :string(64)    
#  user_id         :integer(4)    
#  genre_id        :integer(4)    
#  bpm             :integer(4)    
#  seconds         :integer(4)    default(0)
#  listened_times  :integer(4)    default(0)
#  published       :boolean(1)    default(TRUE)
#  created_at      :datetime      
#  updated_at      :datetime      
#  rating_count    :integer(4)    
#  rating_total    :decimal(10, 2 
#  rating_avg      :decimal(10, 2 
#  key             :integer(4)    
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: songs
#
#  id              :integer(11)   not null, primary key
#  title           :string(60)    
#  original_author :string(60)    
#  description     :string(255)   
#  tone            :string(2)     
#  filename        :string(64)    
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
#  key             :integer(11)   
#
# == Description
#
# The Song model is one of the most important models in Myousica. It serves as a song container
# and implements many finders used by different controllers.
#
# A Song instance currently serves two purposes:
# - Implement a User song, with its associated tracks via the <tt>mixes</tt>
# - Store the <tt>original_author</tt> and Genre informations for a Track, currently not
#   stored in the <tt>tracks</tt> table.
#
# Songs have associated tracks via direct foreign key, too (the <tt>song_id</tt> attribute in
# the Track model), named <tt>children_tracks</tt>. These ones do not appear on the site, and
# serve merely to store genre and author information for the track.
# Tracks are associated this way to a Song when recording live or uploading streams via the
# multitrack SWF.
#
# The <tt>published</tt> attribute sets whether a Song has to be displayed on the site, because
# unpublished songs are scraps created automatically when a registered user enters the multitrack.
# When a project is saved and the song encoded and mixed down, the <tt>published</tt> attribute
# is set to <tt>true</tt> by the MultitrackController#update_song method.
#
# Songs are full-text indexed by Sphinx and can be rated, using the <tt>medlar_acts_as_rated</tt>
# plugin (https://ulisse.adelao.it/rdoc/myousica/plugins/medlar_acts_as_rated).
#
# Each Song has also a playable MP3 stream, handled by the Playable module. The Song model is
# instrumented by calling Playable#has_playable_stream in the class context.
#
# This model implements also the song versioning system, each version is called a <tt>sibling</tt>:
# <b>direct versions</b> are +direct_siblings+ while <b>remote versions</b> are called
# +remote_siblings+.
#
# FIXME: currently tonality information is stored in <b>TWO</b> attributes: <tt>tone</tt> and <tt>
# key</tt>. That's because <tt>tone</tt> is a String that's not feasible for filtering and ordering
# purposes via Sphinx. To not break existing code, the <tt>key</tt> integer attribute was added,
# updated by the +set_key_from_tone+ <tt>before_save</tt> callback.
#
# == Associations
#
# * <b>has_many</b> <tt>mixes</tt>, deleted all upon destroy. [Mix]
# * <b>has_many</b> <tt>tracks</tt> <b>through</b> <tt>mixes</tt> [Track]
# * <b>has_many</b> <tt>children_tracks</tt> [Track]
# * <b>has_many</b> <tt>mlabs</tt> [Mlab]
# * <b>has_many</b> <tt>abuses</tt> [Abuse]
#
# * <b>belongs_to</b> a Genre
# * <b>belongs_to</b> an User
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>title</tt>, <tt>tone</tt> and <tt>seconds</tt> if the 
#   Song is <tt>published</tt>
# * <b>validates_associated</b> Genre and User if the Song is <tt>published</tt>
# * <b>validates_numericality_of</b> <tt>genre_id</tt> and <tt>user_id</tt>, greater than 0,
#   if the Song is <tt>published</tt>
#
# == Callbacks
#
# * <b>before_save</b> +set_key_from_tone+
# * <b>before_destroy</b> +check_for_children_tracks+
#
require 'numeric_to_runtime'
require 'playable'

class Song < ActiveRecord::Base

  define_index do
    has :genre_id, :bpm, :key
    indexes :title, :description, :tone
    indexes :original_author, :as => :author
    indexes genre.name, :as => :genre
    indexes user.country, :as => :country
  end
 
  attr_accessor :mlab

  has_many :mixes, :dependent => :delete_all
  has_many :tracks, :through => :mixes, :order => 'tracks.created_at DESC'  
  has_many :children_tracks, :class_name => 'Track'
  has_many :mlabs, :as => :mixable, :dependent => :delete_all
  has_many :abuses, :as => :abuseable, :dependent => :delete_all, :class_name => 'Abuse'

  belongs_to :genre
  belongs_to :user 
 
  validates_presence_of :title, :tone, :seconds, :if => Proc.new(&:published)
  validates_associated :genre, :user, :if => Proc.new(&:published) 
  validates_numericality_of :genre_id, :user_id, :greater_than => 0, :if => Proc.new(&:published)

  acts_as_rated :rating_range => 0..5    

  before_save    :set_key_from_tone
  before_destroy :check_for_children_tracks

  has_playable_stream

  # Finds all published songs
  #
  def self.find_published(options = {})
    self.find(:all, :conditions => ["songs.published = ?", true])
  end      
  
  # Finds all published songs, ordering them by play count and rating average.
  #
  def self.find_best(options = {})
    self.find(:all, options.merge(:conditions => ['songs.published = ?', true], :order => 'songs.listened_times DESC, songs.rating_avg DESC'))
  end
  
  # Finds all published songs, ordering them by creation time.
  #
  def self.find_newest(options = {})
    self.find(:all, options.merge(:conditions => ["songs.published = ?", true], :order => 'songs.created_at DESC'))
  end

  # Paginates the published songs created in the last month, ordering them by creation time.
  # By default, the first of 7 elements pages is returned. All the <tt>paginate</tt> options
  # are overridable. See the <tt>will_paginate</tt> plugin documentation for details:
  # https://ulisse.adelao.it/rdoc/myousica/plugins/will_paginate
  #
  def self.find_newest_paginated(options = {})
    paginate options.reverse_merge(
             :conditions => ['songs.published = ? AND songs.created_at > ?', true, 1.month.ago],
             :order => 'songs.created_at DESC',
             :per_page => 7,
             :page => 1)
  end
 
  # Paginates published songs for a given genre, ordering them by song title. 15 elements per
  # page are returned.
  #
  def self.find_paginated_by_genre(page, genre)
    paginate :per_page => 15, 
             :conditions => ["songs.published = ? AND genre_id = ?", true, genre.id], 
             :order => "songs.title ASC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  # Paginates published songs for a given User, ordering them by creation time. 3 elements per
  # page are returned. Used by UsersController#show to implement an User personal page.
  #
  # If <tt>options[:skip_blank]</tt> is not nil, only songs that have got tracks are fetched.
  #
  def self.find_paginated_by_user(page, user, options = {})
    conditions = ["songs.published = ? AND songs.user_id = ?", true, user.id]
    conditions[0] += " AND tracks.id IS NOT NULL" if options[:skip_blank]
    paginate :per_page => 3, 
             :conditions => conditions,
             :order => "songs.created_at DESC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  # Paginates published songs for a given Mband, ordering them by creation time. 3 elements
  # per page are returned. Used by MbandsController#show to implement an Mband personal page.
  #
  # If <tt>options[:skip_blank]</tt> is not nil, only songs that have got tracks are fetched.
  #
  def self.find_paginated_by_mband(page, mband, options = {})
    conditions = ["songs.published = ? AND users.id IN (?)", true, mband.members.map(&:id)]
    conditions[0] += " AND tracks.id IS NOT NULL" if options[:skip_blank]
    paginate :per_page => 3, 
             :conditions => conditions,
             :order => "songs.created_at DESC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
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

  # Finds unpublished songs.
  #
  def self.find_unpublished(what, options = {})
    self.find what, options.merge(:conditions => ['published = ?', false])
  end

  # Finds most collaborated songs, using a MySQL-only query (sorry), used by DashboardController#config
  # to implement the Splash configuration.
  #
  def self.find_most_collaborated(options = {})
    collaboration_count = options[:minimum_siblings] || 2
    songs = find_by_sql(["
      SELECT s.*, COUNT(DISTINCT m.song_id) -1 AS siblings_count,
        GROUP_CONCAT(DISTINCT m.song_id ORDER BY m.song_id) AS signature
      FROM mixes m LEFT OUTER JOIN mixes t ON m.track_id = t.track_id
      LEFT OUTER JOIN songs s ON t.song_id = s.id
      LEFT OUTER JOIN songs x ON m.song_id = x.id
      WHERE s.published = ? AND x.published = ?
      GROUP BY s.id
      HAVING siblings_count >= ?
      ORDER BY siblings_count DESC, s.rating_avg DESC
    ", true, true, collaboration_count])

    signatures = []
    songs = songs.select { |song|
      next if signatures.include? song.signature
      signatures.push song.signature
    }
    songs = songs.slice(0, options[:limit].to_i) if options[:limit]

    return songs
  end
  
  # Returns the direct versions of a Song, identified by the presence of a Mix that links
  # the same track to different songs. So, if song <tt>s1</tt> contains tracks <tt>t1</tt>,
  # <tt>t2</tt> and <tt>t3</tt>, every other song <tt>sX</tt> that contains one of those
  # tracks is a version of <tt>s1</tt>.
  #
  # Implementation is with a custom SQL query executed via Song#find_by_sql.
  #
  def direct_siblings(limit = nil)
    limit = "LIMIT #{limit}" if limit
    Song.find_by_sql("
      SELECT
        distinct x.*
      FROM
        mixes s
        INNER JOIN mixes t
          ON s.track_id = t.track_id
        INNER JOIN songs x
          ON t.song_id = x.id
      WHERE
        s.song_id = #{self.id}
      AND
        x.id != #{self.id}
      AND
        x.published = 1
      #{limit}
    ")
  end
  
  # Returns the remote versions of a Song, that is, versions that have two degrees of separation
  # from the current one. It is implemented by fetching all the songs that share at least one
  # track with the current one (direct versions), and then every other song that share a track
  # with them (remote versions). Direct versions are then excluded.
  #
  def indirect_siblings(limit = nil)
    limit = "limit #{limit}" if limit
    mixes = Mix.find_by_sql(["select distinct song_id from mixes where track_id in (select track_id from mixes where song_id = ?) and song_id != ? #{limit}", self.id, self.id])
    return [] if mixes.empty?
    ids = mixes.collect{|m| m.song_id}
    Song.find_by_sql(["
      select
        distinct(mixes.song_id),
        songs.*
      from
        mixes, songs
      where
        track_id in (select track_id from mixes where song_id in (?) )
      and 
        song_id not in (?)
      and
        mixes.song_id = songs.id
      and
        songs.published = 1
    ",  ids, (ids << self.id)
    ])
  end
  
  # Checks whether the passed Song is a direct version of this one.
  #
  def is_a_direct_sibling_of?(song)
    direct_siblings.collect.include?(song)
  end
  
  # Checks whether the passed Song is an indirect version of this one.
  #
  def is_a_indirect_sibling_of?(song)
    indirect_siblings.collect.include?(song)
  end
  
  # Returns the direct siblings count for this track. The +find_most_collaborated+ method
  # precalculates this counter, in order to optimize frequent calls made by the Splash SWF,
  # so this method first checks whether a <tt>siblings_count</tt> attribute is present, if
  # not it proceeds to querying the database for the +direct_siblings+ array and returning
  # its <tt>size</tt>.
  #
  def siblings_count
    (attributes['siblings_count'] || direct_siblings.size).to_i
  end 

  # Increment the <tt>listened_times</tt> counter. Currently called by PlayersController#show.
  #
  def increment_listened_times
    update_attribute(:listened_times, listened_times + 1)
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
  # order for the SongObserver to send out a notification of "new song published on myousica".
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
  
  # Shorthand to fetch the genre name. XXX: looks like this method is unused. remove it.
  #
  def genre_name
    self.genre ? self.genre.name : nil
  end

  # Randomizes the <tt>tone</tt> and the <tt>genre</tt> attributes of this song, used by
  # the MultitrackController#show method, when rendering the editor to users not logged
  # in.
  #
  def randomize!
    self.tone = Myousica::TONES.sort_by{rand}.first
    self.genre = Genre.find(:first, :order => SQL_RANDOM_FUNCTION)
  end

  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.7
  end

  # <tt>before_save</tt> callback that updates both the <tt>tone</tt> and <tt>key</tt>
  # attribute. If the <tt>tone</tt> is an integer, it is put into the <tt>key</tt> and
  # the <tt>tone</tt> updated with the corrisponding tone string as defined in the
  # Myousica module.
  # If <tt>tone</tt> is a tone string, the <tt>key</tt> attribute is updated with the
  # integer index of that tone string, as returned by the Myousica module.
  #
  def set_key_from_tone
    return if self.tone.blank?
    if self.tone =~ /\d+/
      self.key = self.tone.to_i
      self.tone = Myousica::TONES[self.key]
    else
      self.key = Myousica::TONES.index(self.tone.upcase)
    end
  end

  # Checks whether this song has got children tracks, and raises ActiveRecord::ReadOnlyRecord
  # if it has. Used as a barrier to make songs with children tracks undeletable.
  #
  def check_for_children_tracks
    raise ActiveRecord::ReadOnlyRecord if self.published? && self.children_tracks.count > 0
  end
end
