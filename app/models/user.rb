# == Schema Information
# Schema version: 46
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
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
#  type                      :string(255)   
#  motto                     :text          
#  tastes                    :text          
#  remember_token_expires_at :datetime      
#  activated_at              :datetime      
#  friends_count             :integer(11)   
#  age                       :integer(11)   
#  password_reset_code       :string(255)   
#  created_at                :datetime      
#  updated_at                :datetime      
#  rating_count              :integer(11)   
#  rating_total              :decimal(10, 2 
#  rating_avg                :decimal(10, 2 
#  replies_count             :integer(11)   default(0)
#  nickname                  :string(20)    
#  is_admin                  :boolean(1)    
#  status                    :string(3) default('off')
#

require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password                    

  validates_presence_of     :login, :email, :country
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :password, :within => 6..20, :if => :password_required?,
                                       :too_short => 'too short! minimum %d chars',
                                       :too_long => 'too long! maximum %d chars'
  validates_length_of       :login,    :within => 3..20,
                                       :too_short => 'too short! minimum %d chars',
                                       :too_long => 'too long! maximum %d chars'
  validates_length_of       :city,     :maximum => 25,  :allow_nil => true, :allow_blank => true, :message => 'too long! max %d chars'
  validates_length_of       :country,  :maximum => 45,  :allow_nil => true, :allow_blank => true, :message => 'too long! max %d chars!'
  validates_length_of       :motto,    :maximum => 1000, :allow_nil => true, :allow_blank => true, :message => 'too long.. sorry! max %d chars'
  validates_length_of       :tastes,   :maximum => 1000, :allow_nil => true, :allow_blank => true, :message => 'too long.. sorry! max %d chars'

  validates_format_of       :email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create, :message => 'invalid e-mail'
  validates_format_of       :login,    :with => /^[a-z][\w_-]+$/i, :if => Proc.new{|u| !u.login.blank?}, :message => 'only letters, numbers and underscore allowed!'
  validates_format_of       :msn,      :with => /^(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?$/ix, :message => 'invalid MSN address'
  validates_format_of       :skype,    :with => /^([\w\._-]+)?$/ix, :message => 'invalid skype name'
  validates_format_of       :photos_url, :blog_url, :myspace_url,
                                       :with => /^(((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)?$/ix, 
                                       :message => 'invalid internet address'

  validates_uniqueness_of   :login, :email, :case_sensitive => false
  #validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false
  #validates_acceptance_of :eula, :on => :create, :allow_nil => false, :message => "must be abided"

  validates_inclusion_of    :gender, :in => %w(male female other), :allow_nil => true, :allow_blank => true

  before_save :encrypt_password
  before_create :make_activation_code  

  # all string fields are filtered with strip_tags,
  # except the ones in ":except". fields in ":sanitize"
  # are run through sanitize, that uses the white-list
  # sanitizer configured in environment.rb 
  #
  xss_terminate :except => [:email, :msn, :gender, :photos_url, :blog_url, :myspace_url],
                :sanitize => [:motto, :tastes]
  
  has_many :mband_memberships
  has_many :mbands, :through => :mband_memberships, :class_name => 'Mband', :source => :mband,
    :conditions => 'mband_memberships.accepted_at IS NOT NULL', :order => 'mbands.members_count DESC'
  has_many :pending_mband_invitations, :through => :mband_memberships, :class_name => 'Mband', :source => :mband,
    :conditions => 'mband_memberships.accepted_at IS NULL', :order => 'mband_memberships.created_at DESC'

  has_many_friends

  # If type == 'Band'
  has_many :members, :class_name => 'BandMember'
  
  has_many :songs,            :order => 'songs.created_at DESC'
  has_many :tracks,           :order => 'tracks.created_at DESC'
  has_many :published_songs,  :conditions => ["songs.published = ?", true], :order => 'songs.created_at DESC'
  has_many :answers
  has_many :replies
  has_many :photos, :as => :pictureable

  has_many :avatars, :as => :pictureable
  
  has_many :mlabs
  has_many :mlab_tracks, 
    :class_name => 'Mlab',
    :conditions => "mlabs.mixable_type = 'Track'"    
  has_many :mlab_songs, 
    :class_name => 'Mlab',
    :conditions => "mlabs.mixable_type = 'Song'" 
  
  acts_as_rated :rating_range => 0..5
  
  has_private_messages
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :terms_of_service, :eula,
    :first_name, :last_name, :gender, :motto, :tastes, :country, :city, :age,
    :photos_url, :blog_url, :myspace_url, :skype, :msn, :skype_public, :msn_public, :nickname
  
  before_save :check_links
  before_save :check_nickname
                      
  def self.search_paginated(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    with_scope :find => {:conditions => 'activated_at IS NOT NULL'} do # TODO: DRY this common SELECT condition
      paginate(:per_page => options[:per_page], :include => :avatars, :page => options[:page], :conditions => [
        "users.login LIKE ? OR users.country LIKE ? OR users.city LIKE  ?",
        *(Array.new(3).fill("%#{q}%"))
      ])
    end
  end
  
  def is_pending_friends_by_me_with?(user)    
    Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ? AND accepted_at IS NULL", self.id, user.id])
  end
    
  def band?
    self.type == 'Band'
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
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
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

  def status
    if self == User.myousica
      # Myousica is always online
      'on'
    elsif self.updated_at > 30.minutes.ago
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
  
  def self.find_coolest(options = {})
    self.find(:all, options.merge({:conditions => ["activated_at IS NOT NULL AND (type IS NULL OR type = 'User') AND login != 'myousica'"], :order => 'rating_avg DESC'})) 
  end
  
  def self.find_coolest_band_or_deejays(options = {})
    self.find(:all, options.merge({:conditions => ["activated_at IS NOT NULL AND (type = 'Band' OR type = 'Dj') AND login != 'myousica'"], :order => 'rating_avg DESC'})) 
  end
  
  def self.find_best(options = {})
    self.find(:all, options.merge({:conditions => ["songs.id IS NOT NULL AND songs.published = ? AND users.activated_at IS NOT NULL AND (users.type IS NULL OR users.type = 'User') AND users.login != 'myousica'", true], :joins => "LEFT OUTER JOIN songs ON users.id = songs.user_id", :order => 'songs.rating_avg DESC', :include => :avatars})) 
  end
  
  def self.find_best_band_or_deejays(options = {})
    self.find(:all, options.merge({:conditions => ["songs.id IS NOT NULL AND songs.published = ? AND users.activated_at IS NOT NULL AND (users.type = 'Band' OR users.type = 'Dj') AND users.login != 'myousica'", true], :joins => "LEFT OUTER JOIN songs ON users.id = songs.user_id", :order => 'songs.rating_avg DESC', :include => :avatars})) 
  end
  
  def self.find_prolific(options = {})
    qry = "SELECT users.*, songs.title, count(songs.id) AS songs_count FROM users LEFT JOIN songs ON users.id = songs.user_id WHERE (users.type = 'User' OR users.type IS NULL) AND users.activated_at IS NOT NULL AND songs.published = ? AND users.login != 'myousica' GROUP BY users.id ORDER BY songs_count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql([qry, true])
  end
  
  def self.find_prolific_band_or_deejays(options = {})
    qry = "SELECT users.*, songs.title, count(songs.id) AS songs_count FROM users LEFT JOIN songs ON users.id = songs.user_id WHERE (users.type = 'Band' OR users.type = 'Dj') AND users.activated_at IS NOT NULL AND songs.published = ? AND users.login != 'myousica' GROUP BY users.id ORDER BY songs_count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql([qry, true])
  end  
  
  def self.find_friendliest(options)
    self.find(:all, options.merge(:order => 'friends_count DESC', :conditions => "users.activated_at IS NOT NULL AND (users.type IS NULL OR users.type = 'User') AND users.login != 'myousica'"))
  end

  def self.find_friendliest_band_or_deejays(options = {})
    self.find(:all, options.merge(:order => 'friends_count DESC', :conditions => "users.activated_at IS NOT NULL AND (users.type = 'Band' OR users.type = 'Dj') AND users.login != 'myousica'"))
  end

  def self.find_most_admired(options)
    self.find(:all, options.merge(:select => 'users.*, count(friendships.id) as admirers_count', :joins => 'LEFT OUTER JOIN friendships ON friendships.friend_id = users.id AND friendships.accepted_at IS NULL', :conditions => "users.activated_at IS NOT NULL AND (users.type IS NULL OR users.type = 'User') AND users.login != 'myousica'", :group => 'users.id', :order => 'count(friendships.id) DESC'))
  end
  
  def self.find_most_admired_band_or_deejays(options)
    self.find(:all, options.merge(:select => 'users.*, count(friendships.id) as admirers_count', :joins => 'LEFT OUTER JOIN friendships ON friendships.friend_id = users.id AND friendships.accepted_at IS NULL', :conditions => "users.activated_at IS NOT NULL AND (users.type = 'Band' OR users.type = 'Dj') AND users.login != 'myousica'", :group => 'users.id', :order => 'count(friendships.id) DESC'))
  end
  def self.find_newest(options = {})
    self.find(:all, options.merge(:order => 'created_at DESC', :conditions => "activated_at IS NOT NULL AND (users.type IS NULL OR users.type = 'User') AND users.login != 'myousica'"))
  end

  def self.find_newest_band_or_deejays(options = {})
    self.find(:all, options.merge(:order => 'created_at DESC', :conditions => "activated_at IS NOT NULL AND (users.type = 'Band' OR users.type = 'Dj') AND users.login != 'myousica'"))
  end

  def self.find_most_instruments(options = {})
    self.find(:all, options.merge(:select => 'users.*, count(tracks.instrument_id) AS instrument_count', :joins => 'LEFT JOIN tracks ON users.id = tracks.user_id', :conditions => "users.activated_at IS NOT NULL AND (users.type IS NULL OR users.type = 'User') AND tracks.instrument_id IS NOT NULL AND users.login != 'myousica'", :group => 'tracks.instrument_id', :order => 'instrument_count'))
  end
 
  def self.find_most_instruments_band_or_deejays(options = {})
    self.find(:all, options.merge(:select => 'users.*, count(tracks.instrument_id) AS instrument_count', :joins => 'LEFT JOIN tracks ON users.id = tracks.user_id', :conditions => "users.activated_at IS NOT NULL AND (users.type = 'Band' OR users.type = 'Dj') AND tracks.instrument_id IS NOT NULL AND users.login != 'myousica'", :group => 'tracks.instrument_id', :order => 'instrument_count'))
  end

  def self.find_online(options = {})
    self.find(:all, options.merge(:conditions => ['status = ? AND updated_at > ?', 'on', 30.minutes.ago], :order => 'updated_at'))
  end

  def self.count_online(options = {})
    self.count(options.merge(:conditions => ['status = ? AND updated_at > ?', 'on', 30.minutes.ago]))
  end

  def self.find_top_answers_contributors(options = {})
    self.find(:all, options.merge(:include => [:avatars], :order => 'users.replies_count DESC'))
  end

  def self.myousica
    @myousica ||= User.find_by_login('myousica')
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

  def songs_count
    self.songs.count(:conditions => ['songs.published = ?', true])
  end

  def tracks_count
    self.tracks.count
  end

  def ideas_count
    self.tracks.count :conditions => ['tracks.idea = ?', true]
  end
  
  def to_breadcrumb
    login
  end
  
  def instruments
    Instrument.find(:all, :select => 'distinct instruments.*', :joins => 'left outer join tracks on tracks.instrument_id = instruments.id left outer join users on tracks.user_id = users.id', :conditions => ['tracks.user_id = ?', self.id], :order => 'instruments.description')
  end

  def best_songs(options = {})
    self.songs.find(:all, options.merge(:conditions => ['published = ?', true], :order => 'rating_avg DESC'))
  end
  
  def avatar
    avatars.find(:all, :order => 'created_at DESC').first
  end
  
  def find_related_answers
    Answer.find :all, :select => 'DISTINCT',
                      :include => ['replies', 'user'], 
                      :conditions => ['replies.user_id = ? OR answers.user_id = ?', self.id, self.id],
                      :limit => 4
  end   

  def is_leader_of?(mband)
    mband.leader == self
  end

  def mbands_with_more_than_one_member
    self.mbands.find(:all, :conditions => 'members_count > 0', :order => 'rating_avg DESC')
  end

  def profile_completeness
    profile = %w(first_name last_name photos_url myspace_url blog_url skype skype_public msn msn_public)
    complete = profile.select { |attr| !self[attr].blank? }
    (complete.size.to_f / profile.size.to_f * 100.0).round 2
  end

  def rateable_by?(user)
    self.id != user.id
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

    def check_nickname
      self.nickname = self.login if self.nickname.blank?
    end
end
