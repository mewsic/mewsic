# == Schema Information
# Schema version: 20090615124539
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
#  status         :integer(4)    default(-2)
#  created_at     :datetime      
#  updated_at     :datetime      
#  rating_count   :integer(4)    
#  rating_total   :decimal(10, 2 
#  rating_avg     :decimal(10, 2 
#  user_type      :string(10)    
#  delta          :boolean(1)    
#  parent_id      :integer(4)    
#  lft            :integer(4)    
#  rgt            :integer(4)    
#  comments_count :integer(4)    default(0)
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
# The <tt>status</tt> attribute can have 4 values:
# * statuses.public    - accessible and remixable by everyone on the site
# * statuses.private   - accessible and editable only by its author
# * statuses.temporary - scrap, created when entering the multitrac
# * statuses.deleted   - deleted by its author, and completely invisible
#
# Only .public songs are visible in search results, full-text indexed by sphinx using the
# thinking-sphinx plugin (git version, currently 1.1.6).
#
# Before a song can be saved as .public or .private, additional validation is needed, and
# this semantic is implemented in the +published?+ method, added with an :if => condition
# to the validations.
#
# Songs can be rated, using the <tt>medlar_acts_as_rated</tt> plugin
# (https://stage.lime5.it/rdoc/mewsic/plugins/medlar_acts_as_rated).
#
# Each Song has also a playable MP3 stream, handled by the Playable module. The Song model
# is instrumented by calling Playable#has_playable_stream in the class context.
#
# == Associations
#
# * <b>has_many</b> <tt>mixes</tt>, deleted all upon destroy. [Mix]
# * <b>has_many</b> <tt>tracks</tt> <b>through</b> <tt>mixes</tt> [Track]
# * <b>has_many</b> <tt>abuses</tt> [Abuse]
#
# * <b>belongs_to</b> an User
#
# == Validations, ran only if +published?+ returns true
#
# * <b>validates_presence_of</b> <tt>title</tt>, and <tt>seconds</tt>
# * <b>validates_associated</b> User
# * <b>validates_numericality_of</b> <tt>user_id</tt>, greater than 0
#
require 'numeric_to_runtime'
require 'playable'
require 'statuses'

class Song < ActiveRecord::Base

  ## XXX Remove me
  attr_accessor :mlab

  attr_protected :user_id, :listened_times, :comments_count

  belongs_to :user, :polymorphic => true

  has_many :mixes, :conditions => 'deleted = 0'
  has_many :tracks, :through => :mixes, :order => 'mixes.created_at DESC'  
  has_many :featurings, :include => :user

  has_many :mlabs, :as => :mixable
  has_many :abuses, :as => :abuseable, :class_name => 'Abuse'
  has_many :comments, :as => :commentable, :order => 'comments.created_at DESC'

  validates_presence_of :title, :author,      :if => :published?
  validates_associated :user,                 :if => :published?
  validates_length_of :tracks, :minimum => 1, :if => :published?

  before_validation :copy_author_information_from_user, :if => :published?
  before_save :remove_parent_if_it_shares_no_tracks,    :if => :published?

  before_destroy :check_if_deleted
  before_destroy :destroy_mixes

  acts_as_rated :rating_range => 0..5
  acts_as_nested_set
  acts_as_taggable_on :tags

  has_playable_stream

  # Song statuses, and dynamic defininition of public? private? deleted? and temporary? methods
  has_multiple_statuses :public => 1, :private => 2, :deleted => -1, :temporary => -2

  named_scope :public, :conditions => {:status => statuses.public}
  named_scope :private, :conditions => {:status => statuses.private}
  named_scope :stuffable, :conditions => 'status > 0'

  define_index do
    indexes :title, :author, :description
    indexes user.country, :as => :country
    where "status = #{statuses.public}"
    #set_property :delta => true
  end

  # Returns whether a song is accessible by an user via the frontend, so if
  # its status is "public" or "private". Being +published?+ triggers additional
  # validation (presence of title, associated user, minimum 1 track)
  def published?
    [:public, :private].include?(self.status)
  end

  # Song edit policy: a private song is accessible by its creator
  # and all the users that have been added to the featurings list.
  # A public song is accessible by anyone.
  # TODO: Implement only track addition for featurings, and not complete editing
  #
  def editable_by?(user)
    if self.status == :private
      self.user == user || self.featurings.map(&:user).include?(user)
    elsif status == :temporary
      true # XXX FIXME SECURITY HOLE RIGHT HERE: ANY USER CAN MODIFY TEMP SONGS FIXME
    elsif status == :public
      false
    end
  end

  def accessible_by?(user)
    if self.status == :private
      self.user == user || self.featurings.map(&:user).include?(user)
    elsif status == :temporary
      self.user == user
    elsif status == :public
      true
    end
  end

  # Finds all "best" public songs, ordering them by play count and rating average.
  #
  named_scope :best, :order => 'songs.listened_times DESC, songs.rating_avg DESC'

  def self.find_best(options = {})
    self.public.best.find(:all, options)
  end
  
  # Finds all newest public songs, ordered by creation time.
  #
  named_scope :newest, :order => 'songs.created_at DESC' #, :conditions => ['songs.created_at < ?', 1.month.ago] <<- XXX EVIL

  def self.find_newest(options = {})
    self.public.newest.find(:all, options)
  end

  # Paginates newest public songs
  #
  def self.paginate_newest(options = {})
    self.public.newest.paginate(:all, options)
  end
  
  # Shorthand to create an temporary Song. Used by MultitrackController#show, when an user
  # enters the multitrack. It serves to store user data while he is working: because every
  # editing control in the M-Lab uses ajax in-place, Song has to be created in advance.
  #
  def self.create_temporary!
    self.create! :status => statuses.temporary
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
      WHERE s.status = :published AND x.status = :published AND m.deleted = 0
      GROUP BY s.id
      HAVING collaboration_count >= :minimum
      ORDER BY collaboration_count DESC, s.rating_avg DESC
    ", {:published => statuses.public, :minimum => collaboration_count}])

    signatures = []
    songs = songs.select { |song|
      next if signatures.include? song.signature
      signatures.push song.signature
    }
    songs = songs.slice(0, options[:limit].to_i) if options[:limit]

    return songs
  end

  def self.most_played_artist
    @_mpa ||= self.public.count(:group => 'author', :order => 'count_all DESC').first.first
  end

  def self.find_most_played_by_artist(options = {})
    options[:per_page] ||= options.delete(:limit)
    options[:page] ||= 1

    self.public.paginate(:all, options.merge(:conditions => {'author' => most_played_artist}))
  end
 
  # Returns an array of all instruments used into this song.
  #
  def instruments
    @instruments ||= Instrument.find self.tracks.count(:include => :instrument, :group => 'instrument_id').map(&:first)
  end    
  
  # Returns mixable songs, that share at least one track with this one.
  #
  def mixables(options = {})
    track_ids = self.tracks.map(&:id)
    Song.public.find(:all, :include => :mixes,
              :conditions => ['mixes.track_id IN (?) AND mixes.song_id <> ?', track_ids, self.id])
  end
  
  # Checks whether the passed Song is a direct version of this one.
  #
  def is_mixable_with?(song)
    mixables.include?(song)
  end
  
  # Returns the mixables count for this song. The +find_most_collaborated+ method
  # precalculates this counter, in order to optimize frequent calls, so this method
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

  # Checks whether this Song is rateable by the given user.
  # A User Song is not rateable by its creator, a Mband Song is not rateable by its members.
  #
  def rateable_by?(user)
    self.user.rateable_by?(user)
  end

  def create_remix_by(user)
    remix = self.clone
    remix.tracks = self.tracks
    remix.user = user
    remix.status = :private
    remix.save!
    remix.move_to_child_of self
    return remix
  end

  def remix_of?(song)
    self.ancestors.include? song
  end

  def remixes
    self.children
  end

  # Set the :deleted status rather than deleting the record,
  # and delete all the mixes and mlabs linked to this track.
  def delete
    Song.transaction do
      self.status = :deleted
      self.save!

      # sets deleted = 0
      self.mixes.destroy_all

      # actually deletes
      self.mlabs.destroy_all
      self.featurings.destroy_all
    end
  end

  # Shorthand to remove the temporary status of a song, setting it to the one
  # passed via the first parameter (:private by default)
  def preserve!(status = :private)
    self.status = status if self.temporary?
    self.save!
  end

  # Shorthand to publish and save a song.
  # It sets the <tt>@new</tt> instance variable to true if this song was private,
  # used by the SongObserver to send out the "new song published" notification.
  #
  def publish!
    @new = true if self.private?
    self.status = statuses.public
    self.save!
  end

  # Returns true if the song has just been created. See the +publish!+ method for details.
  #
  def new?
    @new
  end

  # Called by the cron runner, to clean up temporary songs created more than a week ago.
  #
  def self.cleanup_temporary
    destroy_all ['status = ? AND created_at < ?', statuses.temporary, 1.week.ago]
  end
  
  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.7
  end

private
  def copy_author_information_from_user
    self.author = self.user.login if self.author.blank?
  end

  def remove_parent_if_it_shares_no_tracks
    if self.parent && (self.tracks & self.parent.tracks).empty?
      self.move_to_root
    end
  end

  # A track can be destroyed only if it is already deleted.
  def check_if_deleted
    raise ActiveRecord::ReadOnlyRecord unless deleted?
  end

  def destroy_mixes
    Mix.delete_all ['song_id = ?', self.id]
  end

end
