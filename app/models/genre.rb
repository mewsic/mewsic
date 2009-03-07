# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: genres
#
#  id   :integer(11)   not null, primary key
#  name :string(255)   
#
# == Description
#
# This model represents a genre of music. It's super-simple because it has got only the
# <tt>name</tt> attribute. Genres cannot be created by the HTML interface, they are only
# managed via <tt>script/console</tt>.
#
# == Associations
#
# * <b>has_many</b> <tt>songs</tt>, ordered by creation time
# * <b>has_many</b> <tt>published_songs</tt>, songs where <tt>published</tt> is true,
#   ordered by creation time.
#
class Genre < ActiveRecord::Base

  has_many :songs,
           :order => 'songs.created_at DESC'

  has_many :published_songs,
           :class_name => 'Song',
           :conditions => ["songs.published = ?", true],
           :order => 'songs.created_at DESC'

  # Finds and paginates a listing of genres, with 5 elements per page. Only genres with published
  # songs are returned.
  def self.find_paginated(page)
    paginate :per_page => 5, :order => "name ASC", :include => [{:songs => :user}], :page => page,
      :conditions => ['songs.published = ?', true]
  end

  # More generic finder for genres with song. No pagination.
  def self.find_with_songs(what, options = {})
    with_scope :find => {:include => :published_songs, :conditions => 'songs.id IS NOT NULL'} do
      find what, options
    end
  end

  # Finds most listened songs for this Genre.
  def find_most_listened(options = {})
    options.merge!({:order => 'songs.listened_times DESC'})
    self.published_songs.find :all, options
  end

  # Finds most prolific users for this Genre.
  def find_most_prolific_users(options = {})
    qry = "SELECT COUNT(*) as count, users.* FROM users LEFT OUTER JOIN songs ON songs.user_id = users.id WHERE (songs.genre_id =?) GROUP BY (users.id) ORDER BY count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql [qry, self.id]
  end

  # Finds the last published songs for this Genre.
  def last_songs(limit = 3)
    self.published_songs.find(:all, :limit => limit, :order => 'created_at DESC')
  end

  # Returns the most recent song updated_at timestamp for this genre
  def updated_at
    self.published_songs.sort_by{|s|s.created_at}.reverse!.first.updated_at
  end

  # Returns the number of published songs for this genre.
  def song_count
    Song.count('genre', :group => 'genre_id', :include => :genre, :conditions => ['published = ? AND genre_id = ?', true, self.id]).flatten.last || 0
  end

  # Puts the genre name into the breadcrumb (see ApplicationHelper#breadcrumb).
  def to_breadcrumb
    self.name
  end

  # Returns an URI-encoded representation of the genre name, for usage in path names.
  def to_param
    CGI.escape self.name.downcase
  end

  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.5
  end

  # Finds a genre by ID or by param, as returned by +to_param+.
  # XXX DRY THESE METHODS! present in models/{user,genre,mband}.rb
  def self.find_from_param(param, options = {})
    param = param.id if param.kind_of? ActiveRecord::Base
    find_method = param.to_s =~ /^\d+$/ ? :find : :find_by_name
    param = CGI.unescape param if find_method == :find_by_name
    send(find_method, param, options) or raise ActiveRecord::RecordNotFound
  end

end
