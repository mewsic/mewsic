# == Schema Information
# Schema version: 46
#
# Table name: songs
#
#  id              :integer(11)   not null, primary key
#  title           :string(255)   
#  original_author :string(255)   
#  description     :string(255)   
#  tone            :string(255)   
#  filename        :string(255)   
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
#

require 'numeric_to_runtime'

class Song < ActiveRecord::Base
  
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

  acts_as_rated :rating_range => 0..5
  
  def self.search_paginated(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    with_scope :find => {:conditions => ['songs.published = ?', true]} do # TODO: DRY this common SELECT condition
      paginate(:per_page => options[:per_page], :page => options[:page], :include => [:genre, {:user => :avatars}], :conditions => [
        "songs.published = ? AND songs.title LIKE ? OR songs.original_author LIKE ? OR songs.description LIKE  ? OR genres.name LIKE ?",
        *(Array.new(4).fill("%#{q}%")).unshift(true)
      ])
    end
  end
  
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
      "select distinct x.original_author, x.title, t.song_id from mixes s inner join mixes t on s.track_id = t.track_id inner join songs x on t.song_id = x.id       
      where x.id != #{self.id} ORDER BY #{SQL_RANDOM_FUNCTION} LIMIT #{limit}"])
  end

  def self.create_unpublished!
    self.create! :published => false
  end

  def self.find_unpublished(what, options = {})
    self.find what, options.merge(:conditions => ['published = ?', false])
  end
  
  def direct_siblings(limit = nil)
    limit = "limit #{limit}" if limit
    Song.find_by_sql("
      select
        distinct x.*
      from
        mixes s
        inner join mixes t
          on s.track_id = t.track_id
        inner join songs x
          on t.song_id = x.id
      where
        s.song_id = #{self.id}
      and
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

end
