# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
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
# == Description
#
# An M-Band is an aggregation of users that play together on myousica, implemented
# with an <tt>has_many :members, :through => :memberships</tt>, where memberships
# are instances of the MbandMembership class.
#
# Every M-Band is managed by a <tt>leader</tt>, that can send invitations to users
# to join. The receiver must accept it before becoming part of the M-Band.
#
# M-Bands have pages very similar to user ones.
#
# == Associations
#
# * <b>has_one</b> <tt>avatar</tt>, destroyed calling *_destroy callbacks upon destroy. [Avatar]
# * <b>has_many</b> <tt>photos</tt>, like above [Photo]
# * <b>has_many</b> <tt>memberships</tt>, like above, [MbandMembership]
# * <b>has_many</b> <tt>members</tt>, <tt>:through => :memberships</tt>, where <tt>accepted_at is not null</tt> [User]
# * <b>belongs_to</b> <tt>leader</tt> [User]
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>name</tt>
# * <b>validates_format_of</b> <tt>name</tt> with a Regexp that allows only letters, numbers, spaces and underscore
# * <b>validates_format_of</b> <tt>photos_url</tt>, <tt>blog_url</tt> and <tt>myspace_url</tt> with a Regexp that
#   checks for a valid URL.
# * <b>validates_uniqueness_of</b> <tt>name</tt>, case insensitive
#
class Mband < ActiveRecord::Base
  
  acts_as_rated :rating_range => 0..5
  
  has_one :avatar, :as => :pictureable, :dependent => :destroy
  has_many :photos, :as => :pictureable, :dependent => :destroy
  has_many :memberships, :class_name => 'MbandMembership', :dependent => :destroy
  has_many :members, :through => :memberships, :class_name => 'User', :source => :user, :conditions => "accepted_at IS NOT NULL"
  
  belongs_to :leader, :class_name => 'User', :foreign_key => 'user_id'
  
  attr_accessible :name, :motto, :tastes, :photos_url, :blog_url, :myspace_url
  
  validates_presence_of   :name
  validates_format_of     :name, :with => /^[a-z]['\w _-]+$/i, :if => Proc.new{|m| !m.name.blank?}, :message => 'only letters, numbers, spaces and underscore allowed!'

  validates_format_of     :photos_url, :blog_url, :myspace_url, :with => /^(((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)?$/ix, :message => 'invalid internet address'

  validates_uniqueness_of :name, :case_sensitive => false
                                                     
  xss_terminate :except => [:name, :photos_url, :blog_url, :myspace_url],
                :sanitize => [:motto, :tastes]
  
  # Checks whether the passed <tt>user</tt> is a member of this Mband
  #
  def band_membership_with(user)
    return false if user == :false
    self.memberships.find(:first, :conditions => ["user_id = ?", user.id])
  end

  # Returns a collection of accepted +MbandMmbership+s
  #
  def accepted_memberships
    self.memberships.find(:all, :conditions => 'accepted_at IS NOT NULL')
  end

  # Returns a collection of pending +MbandMembership+s
  #
  def pending_memberships
    self.memberships.find(:all, :conditions => 'accepted_at IS NULL')
  end
  
  # Prints out the Mband name into the breadcrumb
  #
  def to_breadcrumb
    self.name
  end

  # Returns the Mband name, for compatibility with User#nickname
  #
  def nickname
    self.name
  end

  # URLencodes the downcased mband name
  #
  def to_param
    URI.encode(self.name.downcase.gsub(' ', '+'))
  end

  # Returns all the published songs by the members of this Mband
  #
  def published_songs
    Song.find(:all, :conditions => ["songs.published = ? AND songs.user_id IN (?)", true, self.members.map(&:id)], 
             :order => "songs.created_at DESC")
  end

  # Returns the total count of published songs by the members of this Mband
  #
  def songs_count(options = {})
    self.members.map {|m| m.songs_count(options) }.sum
  end

  # Returns the total count of tracks by the members of this Mband
  #
  def tracks_count
    self.members.map(&:tracks_count).sum
  end

  # Returns the total count of ideas by the members of this Mband
  #
  def ideas_count
    self.members.map(&:ideas_count).sum
  end

  # If all the members share the same status, use it, else, offline.
  # Valid statuses are '<tt>on</tt>', '<tt>rec</tt>' and '<tt>off</tt>'.
  #
  def status
    statuses = self.members.map(&:status).uniq
    if statuses.size == 1
      statuses.first
    else
      'off'
    end
  end

  # Finds an Mband using the string produced by +to_param+, or by numeric 
  # ID. This methods mimics the standard <tt>find</tt>, because it raises
  # an ActiveRecord::RecordNotFound exception if no Mband is found.
  #
  def self.find_from_param(param, options = {})
    param = param.id if param.kind_of? ActiveRecord::Base
    find_method = param.to_s =~ /^\d+$/ ? :find : :find_by_name
    param = URI.decode(param.gsub('+', ' ')) if find_method == :find_by_name
    send(find_method, param, options) or raise ActiveRecord::RecordNotFound
  end

  # Finds the coolest Mbands, that is, Mbands sorted by <tt>rating_avg</tt>. Only Mbands with
  # more than one member are returned.
  #
  def self.find_coolest(options = {})
    find_real options.reverse_merge(:order => 'rating_avg DESC')
  end

  # Finds all the mbands with at least one member
  #
  def self.find_real(options = {})
    find :all, options.merge(:conditions => 'members_count > 1')
  end

  # Calculates profile completeness, by checking whether the 3 configurable URLs (<tt>photos_url</tt>,
  # <tt>myspace_url</tt> and <tt>blog_url</tt>) are compiled or not, and extracts a percent value.
  #
  def profile_completeness
    profile = %w(photos_url myspace_url blog_url)
    complete = profile.select { |attr| !self[attr].blank? }
    (complete.size.to_f / profile.size.to_f * 100.0).round 2
  end

  # Returns an array of all members' countries
  #
  def countries
    self.members.map(&:country).uniq
  end
  
  # Joins the members' countries with a comma
  #
  def compiled_location
    countries.join(', ')
  end

  # Returns true if this Mband is rateable by the passed User object.
  # An Mband is NOT rateable by its members.
  #
  def rateable_by?(user)
    !self.members.include?(user)
  end

  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.6
  end
end
