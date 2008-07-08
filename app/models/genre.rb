# == Schema Information
# Schema version: 41
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
      :conditions => ['songs.published = ?', true]
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

  def to_breadcrumb
    self.name
  end

  def to_param
    URI.encode(self.name.downcase.gsub(' ', '+'))
  end    

  # XXX DRY THESE METHODS! present in models/{user,genre,mband}.rb
  def self.find_from_param(param, options = {})
    param = param.id if param.kind_of? ActiveRecord::Base
    find_method = param.to_s =~ /^\d+$/ ? :find : :find_by_name
    param = URI.decode(param.gsub('+', ' ')) if find_method == :find_by_name
    send(find_method, param, options) or raise ActiveRecord::RecordNotFound
  end

end
