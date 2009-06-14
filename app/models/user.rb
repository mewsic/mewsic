# == Schema Information
# Schema version: 20090312174538
#
# Table name: users
#
#  id                        :integer(4)    not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  remember_token            :string(255)   
#  activation_code           :string(255)   
#  country                   :string(45)    
#  city                      :string(40)    
#  first_name                :string(32)    
#  last_name                 :string(32)    
#  gender                    :string(20)    
#  photos_url                :string(255)   
#  blog_url                  :string(255)   
#  myspace_url               :string(255)   
#  skype                     :string(255)   
#  msn                       :string(255)   
#  msn_public                :boolean(1)    
#  skype_public              :boolean(1)    
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  string                    :string(40)    
#  biography                 :text          
#  tastes                    :text          
#  remember_token_expires_at :datetime      
#  activated_at              :datetime      
#  friends_count             :integer(4)    
#  age                       :integer(4)    
#  password_reset_code       :string(255)   
#  created_at                :datetime      
#  updated_at                :datetime      
#  rating_count              :integer(4)    
#  rating_total              :decimal(10, 2 
#  rating_avg                :decimal(10, 2 
#  is_admin                  :boolean(1)    
#  status                    :string(3)     default("off")
#  name_public               :boolean(1)    
#  multitrack_token          :string(64)    
#  podcast_public            :boolean(1)    default(TRUE)
#  profile_views             :integer(4)    default(0)
#  comments_count            :integer(4)    default(0)
#  writings_count            :integer(4)    default(0)
#

require 'digest/sha1'
class User < ActiveRecord::Base
  
  define_index do
    indexes :login, :biography, :tastes, :country
    where 'activated_at IS NOT NULL'
    #set_property :delta => true
  end
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password                    

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :password, :within => 6..20, :if => :password_required?,
                                       :too_short => 'too short! minimum {{count}} chars',
                                       :too_long => 'too long! maximum {{count}} chars'
  validates_length_of       :login,    :within => 3..20,
                                       :too_short => 'too short! minimum {{count}} chars',
                                       :too_long => 'too long! maximum {{count}} chars'
  validates_length_of       :city,     :maximum => 25,  :allow_nil => true, :allow_blank => true, :message => 'too long! max {{count}} chars'
  validates_length_of       :country,  :maximum => 45,  :allow_nil => true, :allow_blank => true, :message => 'too long! max {{count}} chars!'
  validates_length_of       :biography, :maximum => 1500, :allow_nil => true, :allow_blank => true, :message => 'too long.. sorry! max {{count}} chars'
  validates_length_of       :tastes,   :maximum => 1500, :allow_nil => true, :allow_blank => true, :message => 'too long.. sorry! max {{count}} chars'

  validates_format_of       :email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create, :message => 'invalid e-mail'
  validates_format_of       :login,    :with => /^[a-z][\w_-]+$/i, :if => Proc.new{|u| !u.login.blank?}, :message => 'only letters, numbers and underscore allowed!'
  validates_format_of       :msn,      :with => /^(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?$/ix, :message => 'invalid MSN address'
  validates_format_of       :skype,    :with => /^([\w\._-]+)?$/ix, :message => 'invalid skype name'
  validates_format_of       :photos_url, :blog_url, :myspace_url,
                                       :with => /^(((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)?$/ix, 
                                       :message => 'invalid internet address'

  validates_uniqueness_of   :login, :email, :case_sensitive => false

  validates_inclusion_of    :gender, :in => %w(male female other), :allow_nil => true, :allow_blank => true

  before_save :encrypt_password
  before_create :make_activation_code  

  # all string fields are filtered with strip_tags,
  # except the ones in ":except". fields in ":sanitize"
  # are run through sanitize, that uses the white-list
  # sanitizer configured in environment.rb 
  #
  xss_terminate :except => [:email, :msn, :gender, :photos_url, :blog_url, :myspace_url, :facebook_uid],
                :sanitize => [:biography, :tastes]
  
  has_many :mband_memberships
  has_many :mbands, :through => :mband_memberships, :class_name => 'Mband', :source => :mband,
    :conditions => 'mband_memberships.accepted_at IS NOT NULL', :order => 'mbands.members_count DESC'
  has_many :pending_mband_invitations, :through => :mband_memberships, :class_name => 'Mband', :source => :mband,
    :conditions => 'mband_memberships.accepted_at IS NULL', :order => 'mband_memberships.created_at DESC'

  has_many_friends

  has_many :songs, :as => :user, :order => 'songs.created_at DESC'
  has_many :tracks, :order => 'tracks.created_at DESC'
  has_many :featurings

  has_many :answers, :order => 'answers.created_at DESC'
  has_many :photos, :as => :pictureable

  has_many :comments, :as => :commentable, :order => 'comments.created_at DESC'
  has_many :writings, :source => :comment, :class_name => 'Comment'

  has_one :avatar, :as => :pictureable

  # If you're getting a EagerLoadPolymorphicError because of
  # this :include => :mixable, try to avoid your .count on
  # the association if possible (e.g. use .size), or if you
  # can't, *comment* it out. A better solution may be in front
  # of your nose but you're still not seeing it. -vjt
  has_many :mlabs, :include => :mixable
  
  has_many :abuses, :as => :abuseable

  acts_as_rated :rating_range => 0..5
  acts_as_tagger
  
  has_private_messages
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :password, :password_confirmation, :first_name, :last_name, :name_public,
    :gender, :biography, :tastes, :country, :city, :birth_date,
    :photos_url, :blog_url, :myspace_url,
    :skype, :msn, :skype_public, :msn_public, :podcast_public
  attr_readonly :comments_count, :writings_count, :profile_views, :facebook_uid
  
  before_save :check_links

  named_scope :active, :conditions => 'activated_at IS NOT NULL'
  named_scope :coolest, :order => 'rating_count DESC, rating_avg DESC'
  named_scope :newest, :order => 'activated_at DESC'

  # Returns the user avatar if it's set, or the default avatar if not.
  #
  def avatar_with_default
    avatar_without_default || Avatar.find_by_filename('default_avatar.png')
  end
  alias_method_chain :avatar, :default

  def nickname
    self.login
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end

  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end    

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end
    
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    login_field = login =~ /@/ ? 'email' : 'login'
    u = find :first, :conditions => ["#{login_field} = ? and activated_at IS NOT NULL", login]
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.status                    = 'off'
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def enter_multitrack!
    self.multitrack_token = encrypt("#{email}--#{Time.now}")
    save(false)
  end

  def leave_multitrack!
    self.multitrack_token = nil
    save(false)
  end

  def multitrack?
    !self.multitrack_token.nil?
  end

  def status
    if self.updated_at > 30.minutes.ago
      # if this record has been updated in the last 30 minutes,
      # trust the recorded status.
      self.read_attribute :status
    else
      # else, this user went away witouth logging out. offline.
      'off'
    end
  end

  # legacy, can be removed, but it could prove useful.
  def online_now?
    %w(on rec).include? self.status
  end

  def compiled_location
    (result = [city, country].compact.join(", ")).blank? ? "Unknown" : result
  end

  def to_param
    self.login.downcase
  end

  def self.from_param(param)
    return param.id if param.kind_of? ActiveRecord::Base
    return param.to_i if param.to_s =~ /^\d+$/ 
    (User.find_by_login(param) or raise ActiveRecord::RecordNotFound).id
  end

  def self.find_from_param(param, options = {})
    param = param.id if param.kind_of? ActiveRecord::Base
    find_method = param.to_s =~ /^\d+$/ ? :find : :find_by_login
    send(find_method, param, options.merge(:conditions => "users.activated_at IS NOT NULL")) or raise ActiveRecord::RecordNotFound
  end
  
  # Finds all activated users.
  #
  def self.find_activated(options = {})
    self.find(:all, options.merge(:conditions => "activated_at IS NOT NULL"))
  end

  def self.count_activated(options = {})
    self.count(:conditions => "activated_at IS NOT NULL")
  end

  def self.find_coolest(options = {})
    self.active.coolest.find(:all, options)
  end

  def self.find_best(options = {})
    self.find(:all, options.merge({:conditions => ["songs.id IS NOT NULL AND songs.status = ? AND users.activated_at IS NOT NULL", Song.statuses.public], :joins => "LEFT OUTER JOIN songs ON users.id = songs.user_id", :order => 'songs.rating_avg DESC', :include => :avatar})) 
  end
  
  def self.find_prolific(options = {})
    qry = "SELECT users.*, songs.title, count(songs.id) AS songs_count FROM users LEFT JOIN songs ON users.id = songs.user_id WHERE users.activated_at IS NOT NULL AND songs.status = ? GROUP BY users.id ORDER BY songs_count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql([qry, Song.statuses.public])
  end
  
  def self.find_friendliest(options)
    self.find(:all, options.merge(:order => 'friends_count DESC', :conditions => "users.activated_at IS NOT NULL"))
  end

  def self.find_most_admired(options)
    self.find(:all, options.merge(:select => 'users.*, count(friendships.id) as admirers_count',
                                  :joins => 'LEFT OUTER JOIN friendships ON friendships.friend_id = users.id AND friendships.accepted_at IS NULL',
                                  :conditions => "users.activated_at IS NOT NULL", :group => 'users.id', :order => 'count(friendships.id) DESC'))
  end
  
  def self.find_newest(options = {})
    self.find(:all, options.merge(:order => 'created_at DESC', :conditions => 'activated_at IS NOT NULL'))
  end
  
  def self.find_paginated_best(options = {})
    options.reverse_update(:page => 1, :per_page => 3)
    paginate(options.merge({:conditions => ["songs.id IS NOT NULL AND songs.status = ? AND users.activated_at IS NOT NULL", Song.statuses.public],
                           :joins => "LEFT OUTER JOIN songs ON users.id = songs.user_id", :order => 'songs.rating_avg DESC', :include => :avatar})) 
  end

  def self.find_paginated_newest(options = {})
    options.reverse_update(:page => 1, :per_page => 3)
    paginate(options.merge(:order => 'created_at DESC', :conditions => "activated_at IS NOT NULL"))
  end

  def self.find_paginated_prolific(options = {})
    options.reverse_update(:page => 1, :per_page => 3)
    paginate(options.merge(
      :select => "users.*, songs.title, count(songs.id) AS songs_count",
      :joins => "LEFT JOIN songs ON users.id = songs.user_id",
      :conditions => "users.activated_at IS NOT NULL",
      :group => "users.id",
      :order => "songs_count DESC"      
    ))
  end

  def self.find_paginated_coolest(options = {})
    options.reverse_update(:page => 1, :per_page => 9)
    paginate(options.merge({:conditions => 'activated_at IS NOT NULL', :order => 'rating_avg DESC'})) 
  end

  def self.find_most_instruments(options = {})
    self.find(:all, options.merge(:select => 'users.*, count(distinct tracks.instrument_id) AS instrument_count', :joins => 'LEFT JOIN tracks ON users.id = tracks.user_id', :conditions => "users.activated_at IS NOT NULL AND tracks.instrument_id IS NOT NULL", :group => 'users.id', :order => 'instrument_count DESC'))
  end

  def self.find_online(options = {})
    self.find(:all, options.merge(:conditions => ['status IN (?) AND updated_at > ?', %w(on rec), 30.minutes.ago], :order => 'updated_at'))
  end

  def self.count_online(options = {})
    self.count(options.merge(:conditions => ['status IN (?) AND updated_at > ?', %w(on rec), 30.minutes.ago]))
  end

  def self.find_top_answers_contributors(options = {})
    self.find(:all, options.merge(:include => [:avatar], :order => 'users.writings_count DESC'))
  end

  # Finds all the activated users that have an avatar and have created most
  # tracks, ordering by track count.
  #
  def self.find_top_musicians(options = {})
    options.assert_valid_keys :limit
    qry = "SELECT COUNT(tracks.id) AS tracks_count, users.*
           FROM users INNER JOIN tracks ON tracks.user_id = users.id
           INNER JOIN pictures ON (pictures.pictureable_id = users.id AND pictures.pictureable_type = 'User' AND pictures.type = 'Avatar')
           WHERE (users.activated_at IS NOT NULL) GROUP BY users.id HAVING tracks_count > 2 ORDER BY #{SQL_RANDOM_FUNCTION}"
    qry += " LIMIT #{options[:limit]}" if options[:limit]
    self.find_by_sql qry
  end

  def self.find_countries
    find(:all, :select => 'country', :group => 'country', :order => 'country').map(&:country)
  end

  def self.find_players_of_artist(artist, options = {})
    options[:order] ||= SQL_RANDOM_FUNCTION
    self.active.find(:all, options.merge(:include => :songs, :group => 'songs.id',
                                         :conditions => ['songs.author = ?', artist]))
  end

  def is_pending_friends_by_me_with?(user)
    Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ? AND accepted_at IS NULL", self.id, user.id])
  end

  def friends(options = {})
    options.assert_valid_keys :limit, :conditions, :order

    limit = options[:limit] ? "limit #{options[:limit]}" : nil
    conditions = options[:conditions] ? "AND (#{self.class.send! :sanitize_sql, options[:conditions]})" : nil
    order = options[:order] || 'f.accepted_at DESC'

    User.find_by_sql "select users.* from users inner join friendships f on (users.id = f.friend_id or users.id = f.user_id) where users.id != #{id} and (f.friend_id = #{id} or f.user_id = #{id}) and f.accepted_at is not null #{conditions} order by #{order} #{limit}"
  end

  def update_friends_count
    @friends_count = nil
    update_attribute('friends_count', friends_for_me.count + friends_by_me.count)
    attributes['friends_count']
  end

  def friends_count
    @friends_count ||= (attributes['friends_count'] || update_friends_count)
  end

  def admirers
    pending_friends_for_me
  end

  def admirers_count
    @admirers_count ||= (attributes['admirers_count'] || admirers.count).to_i
  end

  def songs_count(options = {})
    if options[:skip_blank] # XXX remove me, because no blank songs are allowed anymore..
      self.songs.public.count(:include => :tracks, :conditions => 'mixes.id IS NOT NULL')
    else
      self.songs.public.count
    end
  end

  def tracks_count
    self.tracks.count
  end

  def to_breadcrumb
    login
  end
  
  def instruments
    Instrument.find(:all, :select => 'distinct instruments.*', :joins => 'left outer join tracks on tracks.instrument_id = instruments.id left outer join users on tracks.user_id = users.id', :conditions => ['tracks.user_id = ?', self.id], :order => 'instruments.description')
  end

  def best_songs(options = {})
    self.songs.public.find(:all, :order => 'rating_avg DESC')
  end
  
  #def avatar
  #  avatars.find(:all, :order => 'created_at DESC').first
  #end
  
  def is_leader_of?(mband)
    mband.leader == self
  end

  def mbands_with_more_than_one_member
    self.mbands.find(:all, :conditions => 'members_count > 0', :order => 'rating_avg DESC')
  end

  def profile_completeness
    profile = %w(first_name last_name name_public photos_url myspace_url blog_url skype skype_public msn msn_public)
    complete = profile.select { |attr| !self[attr].blank? }
    (complete.size.to_f / profile.size.to_f * 100.0).round 2
  end

  def rateable_by?(user)
    self.id != user.id
  end

  def profile_viewed_by(viewer)
    ProfileView.create :user => self, :viewer => viewer
  end

  def his
    self.gender == 'female' ? 'her' : 'his'
  end

  def him
    self.gender == 'female' ? 'her' : 'him'
  end

  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.6
  end

  protected
    # before filter 
    def encrypt_password      
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end    
    
    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def check_links
      %w[photos_url blog_url myspace_url].each do |attr|
        unless self.send(attr).blank?
          self.send("#{attr}=", "http://#{self.send(attr)}") unless self.send(attr) =~ /^http:\/\//
        end
      end
    end
end
