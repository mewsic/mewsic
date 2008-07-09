# == Schema Information
# Schema version: 43
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

class Song < ActiveRecord::Base
  
  attr_accessor :mlab
  
  has_many :mixes, :dependent => :destroy
  has_many :tracks, :through => :mixes, :order => 'tracks.created_at DESC'  
  has_many :children_tracks, :class_name => 'Track'
  has_many :mlabs, :as => :mixable


  belongs_to :genre
  belongs_to :user 
  
  has_many :abuses, :as => :abuseable
  
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
  
  # TODO: STUB fino ai criteri di best
  def self.find_best(options = {})
    self.find(:all, options)
  end
  
  def self.find_newest(options = {})
    options.merge!({:order => 'songs.created_at DESC'})
    options[:conditions] = ["songs.published = ?", true]
    self.find(:all, options)
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
             :order => "songs.title ASC",
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
    
  # STUB: sino all'implementazione degli strumenti
  def instruments
    ['sassofono', 'batteria', 'anoleso']
  end    
  
  def self.find_random_direct_siblings(limit = 5)    
    Mix.find_by_sql([
      "select distinct x.original_author, x.title, t.song_id from mixes s inner join mixes t on s.track_id = t.track_id inner join songs x on t.song_id = x.id       
      where x.id != #{self.id} ORDER BY #{SQL_RANDOM_FUNCTION} LIMIT #{limit}"])
  end
  
  def direct_siblings(limit = 5)
    Mix.find_by_sql("select distinct x.original_author, x.title, t.song_id from mixes s inner join mixes t on s.track_id = t.track_id inner join songs x on t.song_id = x.id where s.song_id = #{self.id} and x.id != #{self.id} LIMIT #{limit}")
  end
  
  def indirect_siblings(limit = 5)
    mixes = Mix.find_by_sql(["select distinct song_id from mixes where track_id in (select track_id from mixes where song_id = ?) and song_id != ?", self.id, self.id])
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
    direct_siblings.collect {|s| s.song_id}.include?(song.id)
  end
  
  def is_a_indirect_sibling_of?(song)
    indirect_siblings.collect {|s| s.song_id.to_i}.include?(song.id)
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
    hours,   remainig = self.seconds.divmod(3600)
    minutes, remainig = remainig.divmod(60)
    seconds = remainig    
    "#{zerofill(hours, 2)}:#{zerofill(minutes, 2)}:#{zerofill(seconds, 2)}"
  end
  
  def to_breadcrumb
    self.title
  end    

  def self.cleanup_unpublished
    delete_all ['published = ? && created_at < ?', false, 1.week.ago]
  end

private

  def zerofill(number, length)
    string = number.to_s
    (length - string.size).times{ string = "0#{string}"}
    string
  end  
end
