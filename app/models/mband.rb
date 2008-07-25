# == Schema Information
# Schema version: 49
#
# Table name: mbands
#
#  id            :integer(11)   not null, primary key
#  name          :string(255)   
#  photos_url    :string(255)   
#  blog_url      :string(255)   
#  myspace_url   :string(255)   
#  motto         :text          
#  tastes        :text          
#  friends_count :integer(11)   
#  user_id       :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#  rating_count  :integer(11)   
#  rating_total  :decimal(10, 2 
#  rating_avg    :decimal(10, 2 
#  members_count :integer(11)   default(0)
#

class Mband < ActiveRecord::Base
  
  acts_as_rated :rating_range => 0..5
  
  has_many :avatars, :as => :pictureable, :dependent => :destroy
  has_many :photos, :as => :pictureable, :dependent => :destroy
  has_many :memberships, :class_name => 'MbandMembership', :dependent => :destroy
  has_many :members, :through => :memberships, :class_name => 'User', :source => :user, :conditions => "accepted_at IS NOT NULL"
  
  belongs_to :leader, :class_name => 'User', :foreign_key => 'user_id'
  
  attr_accessible :name, :motto, :tastes, :photos_url, :blog_url, :myspace_url
  
  validates_presence_of   :name
  validates_format_of     :name, :with => /^[a-z]['\w ]+$/i, :if => Proc.new{|m| !m.name.blank?}, :message => 'only letters, numbers, spaces and underscore allowed!'

  validates_format_of     :photos_url, :blog_url, :myspace_url, :with => /^(((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)?$/ix, :message => 'invalid internet address'

  validates_uniqueness_of :name, :case_sensitive => false
                                                     
  xss_terminate :except => [:name, :photos_url, :blog_url, :myspace_url],
                :sanitize => [:motto, :tastes]
  
  def band_membership_with(user)
    self.memberships.find(:first, :conditions => ["user_id = ?", user.id])
  end

  def accepted_memberships
    self.memberships.find(:all, :conditions => 'accepted_at IS NOT NULL')
  end

  def pending_memberships
    self.memberships.find(:all, :conditions => 'accepted_at IS NULL')
  end
  
  def to_breadcrumb
    self.name
  end

  def nickname
    self.name
  end

  def to_param
    URI.encode(self.name.downcase.gsub(' ', '+'))
  end

  def published_songs
    Song.find(:all, :conditions => ["songs.published = ? AND songs.user_id IN (?)", true, self.members.map(&:id)], 
             :order => "songs.created_at DESC")
  end

  def songs_count
    self.members.map(&:songs_count).sum
  end

  def tracks_count
    self.members.map(&:tracks_count).sum
  end

  def ideas_count
    self.members.map(&:ideas_count).sum
  end

  # If all the members share the same status, use it.
  # Else, offline.
  def status
    statuses = self.members.map(&:status).uniq
    if statuses.size == 1
      statuses.first
    else
      'off'
    end
  end

  def self.find_from_param(param, options = {})
    param = param.id if param.kind_of? ActiveRecord::Base
    find_method = param.to_s =~ /^\d+$/ ? :find : :find_by_name
    param = URI.decode(param.gsub('+', ' ')) if find_method == :find_by_name
    send(find_method, param, options) or raise ActiveRecord::RecordNotFound
  end

  def self.find_coolest(options = {})
    find :all, options.merge(:order => 'rating_avg DESC', :conditions => 'members_count > 1')
  end

  def profile_completeness
    profile = %w(photos_url myspace_url blog_url)
    complete = profile.select { |attr| !self[attr].blank? }
    (complete.size.to_f / profile.size.to_f * 100.0).round 2
  end

  def countries
    self.members.map(&:country).uniq
  end
  
  def compiled_location
    countries.join(', ')
  end

  def rateable_by?(user)
    !self.members.include?(user)
  end
end
