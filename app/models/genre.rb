# == Schema Information
# Schema version: 15
#
# Table name: genres
#
#  id   :integer(11)   not null, primary key
#  name :string(255)   
#

class Genre < ActiveRecord::Base
  
  has_many :songs,
           :order => 'songs.created_at DESC'
           
  has_many :published_songs,
           :class_name => 'Song', 
           :conditions => ["songs.published = ?", true],
           :order => 'songs.created_at DESC'
  
  def self.find_paginated(page)
    paginate :per_page => 5, :order => "name ASC", :include => [{:songs => :user}], :page => page,
      :conditions => 'songs.title IS NOT NULL'
  end
  
  def find_most_listened(options = {})
    options.merge!({:order => 'songs.listened_times DESC'})
    self.published_songs.find :all, options
  end
  
  def find_most_prolific_users(options = {})
    qry = "SELECT COUNT(*) as count, users.* FROM users LEFT OUTER JOIN songs ON songs.user_id = users.id WHERE (songs.genre_id =?) GROUP BY (users.id) ORDER BY count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql [qry, self.id]
  end
  
  def last_songs(limit = 3)
    self.published_songs.find(:all, :limit => limit, :order => 'created_at DESC')
  end
  
end
