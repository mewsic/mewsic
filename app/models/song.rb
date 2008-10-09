require 'numeric_to_runtime'
require 'playable'

class Song < ActiveRecord::Base
  
  # acts_as_sphinx
  # extend SphinxWillPagination
  # 
  define_index do
    has :genre_id
    has :bpm
    has :key
    has user.country, :as => :user_country
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

  # def self.search_paginated(q, options = {})
  #     options = {:per_page => 6, :page => 1}.merge(options)
  #     paginate(:per_page => options[:per_page], :page => options[:page], :include => [:genre, {:user => :avatars}], :conditions => [
  #       "songs.published = ? AND songs.title LIKE ? OR songs.original_author LIKE ? OR songs.description LIKE  ? OR genres.name LIKE ?",
  #       *(Array.new(4).fill("%#{q}%")).unshift(true)
  #     ])
  #   end
  
  def self.find_published(options = {})
    self.find(:all, :conditions => ["songs.published = ?", true])
  end      
  
  def self.find_best(options = {})
    self.find(:all, options.merge(:conditions => ['songs.published = ?', true], :order => 'songs.listened_times DESC, songs.rating_avg DESC'))
  end
  
  def self.find_newest(options = {})
    self.find(:all, options.merge(:conditions => ["songs.published = ?", true], :order => 'songs.created_at DESC'))
  end

  def self.find_newest_paginated(options = {})
    paginate options.reverse_merge(
             :conditions => ['songs.published = ? AND songs.created_at > ?', true, 1.month.ago],
             :order => 'songs.created_at DESC',
             :per_page => 7,
             :page => 1)
  end
 
  def self.find_paginated_by_genre(page, genre)
    paginate :per_page => 15, 
             :conditions => ["songs.published = ? AND genre_id = ?", true, genre.id], 
             :order => "songs.title ASC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  # TODO: Unire i due metodi in uno unico 
  def self.find_paginated_by_user(page, user, options = {})
    conditions = ["songs.published = ? AND songs.user_id = ?", true, user.id]
    conditions[0] += " AND tracks.id IS NOT NULL" if options[:skip_blank]
    paginate :per_page => 3, 
             :conditions => conditions,
             :order => "songs.created_at DESC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  def self.find_paginated_by_mband(page, mband, options = {})
    conditions = ["songs.published = ? AND users.id IN (?)", true, mband.members.map(&:id)]
    conditions[0] += " AND tracks.id IS NOT NULL" if options[:skip_blank]
    paginate :per_page => 3, 
             :conditions => conditions,
             :order => "songs.created_at DESC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
    
  def instruments
    self.tracks.count('instrument', :include => :instrument, :group => 'instrument_id').map { |id, count| Instrument.find(id) }
  end    
  
  def self.create_unpublished!
    self.create! :published => false
  end

  def self.find_unpublished(what, options = {})
    self.find what, options.merge(:conditions => ['published = ?', false])
  end

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
  
  def is_a_direct_sibling_of?(song)
    direct_siblings.collect.include?(song)
  end
  
  def is_a_indirect_sibling_of?(song)
    indirect_siblings.collect.include?(song)
  end
  
  def siblings_count
    (attributes['siblings_count'] || direct_siblings.size).to_i
  end 
  
  def update_children_tracks_count
    self.children_tracks_count = self.children_tracks.count(true)
    save    
  end
  
  def increment_listened_times
    update_attribute(:listened_times, listened_times + 1)
  end
  
  def length
    seconds.to_runtime
  end
  
  def to_breadcrumb
    self.title
  end    

  def rateable_by?(user)
    self.user_id != user.id
  end

  def publish!
    @new = true if !self.published?
    self.published = true
    self.save!
  end

  # Returns true if the song has just been created
  def new?
    @new
  end

  # Called by the cron runner
  #
  def self.cleanup_unpublished
    songs = find_by_sql(['select songs.id from songs
      left outer join tracks on tracks.song_id = songs.id
      where songs.published = ? and songs.created_at < ?
      group by songs.id having count(tracks.id) = 0', false, 1.week.ago])

    delete_all ['id in (?)', songs.map(&:id)] unless songs.empty?
  end
  
  #called by mlab.js 
  def genre_name
    self.genre ? self.genre.name : nil
  end

  def randomize!
    self.tone = Myousica::TONES.sort_by{rand}.first
    self.genre = Genre.find(:first, :order => SQL_RANDOM_FUNCTION)
  end

  def set_key_from_tone
    return if self.tone.blank?
    if self.tone =~ /\d+/
      self.key = self.tone.to_i
      self.tone = Myousica::TONES[self.key]
    else
      self.key = Myousica::TONES.index(self.tone.upcase)
    end
  end

  def check_for_children_tracks
    raise ActiveRecord::ReadOnlyRecord if self.published? && self.children_tracks.count > 0
  end
end
