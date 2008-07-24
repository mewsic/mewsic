require 'numeric_to_runtime'

class Song < ActiveRecord::Base
  
  # acts_as_sphinx
  # extend SphinxWillPagination
  # 
  define_index do
    has :genre_id
    has :bpm
    has :tone
    has user.country, :as => :user_country
  end
 
  
  attr_accessor :mlab
  
  has_many :mixes, :dependent => :destroy
  has_many :tracks, :through => :mixes, :order => 'tracks.created_at DESC'  
  has_many :children_tracks, :class_name => 'Track'
  has_many :mlabs, :as => :mixable
  has_many :abuses, :as => :abuseable

  belongs_to :genre
  belongs_to :user 
  
  validates_presence_of :title, :tone, :seconds, :genre_id, :user_id, :if => Proc.new(&:published)
  validates_associated :genre, :user, :if => Proc.new(&:published) 
  validates_each :genre_id, :user_id, :if => Proc.new(&:published) do |model, attr, value|
    model.errors.add(attr, "invalid #{attr}") if value.to_i.zero?
  end

  acts_as_rated :rating_range => 0..5    

  before_validation :clean_up_filename

  after_destroy :delete_sound_file


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
    self.find(:all, options.merge(:order => 'songs.created_at DESC', :conditions => ["songs.published = ?", true]))
  end
 
  def self.find_paginated_by_genre(page, genre)
    paginate :per_page => 15, 
             :conditions => ["songs.published = ? AND genre_id = ?", true, genre.id], 
             :order => "songs.title ASC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  # TODO: Unire i due metodi in uno unico 
  def self.find_paginated_by_user(page, user)
    paginate :per_page => 3, 
             :conditions => ["songs.published = ? AND songs.user_id = ?", true, user.id], 
             :order => "songs.updated_at DESC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
  
  def self.find_paginated_by_mband(page, mband)
    paginate :per_page => 3, 
             :conditions => ["songs.published = ? AND users.id IN (?)", true, mband.members.map(&:id)], 
             :order => "songs.updated_at DESC",
             :include => [:user, {:tracks => :instrument}], 
             :page => page
  end
    
  def instruments
    self.tracks.count('instrument', :include => :instrument, :group => 'instrument_id').map { |id, count| Instrument.find(id) }
  end    
  
  def self.find_random_direct_siblings(limit = 5)    
    Mix.find_by_sql([
      "SELECT DISTINCT x.original_author, x.title, t.song_id
       FROM mixes s INNER JOIN mixes t ON s.track_id = t.track_id INNER JOIN songs x ON t.song_id = x.id
       ORDER BY #{SQL_RANDOM_FUNCTION} LIMIT #{limit}"])
  end

  def self.create_unpublished!
    self.create! :published => false
  end

  def self.find_unpublished(what, options = {})
    self.find what, options.merge(:conditions => ['published = ?', false])
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
    120
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

  # Called by the cron runner
  #
  def self.cleanup_unpublished
    songs = find_by_sql(['select songs.id from songs left outer join tracks on tracks.song_id = songs.id where songs.published = ? and songs.created_at < ? group by songs.id having count(tracks.id) = 0', false, 1.week.ago])
    delete_all ['id in (?)', songs.map(&:id)] unless songs.empty?
  end
  
  #called by mlab.js 
  def genre_name
    self.genre ? self.genre.name : nil
  end

  def public_filename(type = :stream)
    return nil unless self.filename

    filename = self.filename.dup
    filename.sub! /\.mp3$/, '.png' if type == :waveform

    APPLICATION[:audio_url] + '/' + filename
  end

private

  def delete_sound_file
    File.unlink File.join(APPLICATION[:media_path], self.filename)
  end

  def clean_up_filename
    self.filename = File.basename(self.filename) if self.filename
  end

end
