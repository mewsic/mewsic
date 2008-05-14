# == Schema Information
# Schema version: 15
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
#  first_name                :string(255)   
#  last_name                 :string(255)   
#  gender                    :string(255)   default("male")
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
#

require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password                    

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..20, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..20
  validates_length_of       :city,     :maximum => 25, :allow_nil => true, :allow_blank => true
  validates_length_of       :country,  :maximum => 45, :allow_nil => true, :allow_blank => true
  validates_length_of       :motto,    :maximum => 250, :allow_nil => true, :allow_blank => true
  validates_length_of       :tastes,   :maximum => 250, :allow_nil => true, :allow_blank => true

  validates_format_of       :email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create
  validates_format_of       :msn,      :with => /^(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?$/ix
  validates_format_of       :skype,    :with => /^([\w\._-]+)?$/ix
  validates_format_of       :photos_url, :blog_url, :myspace_url,
                                       :with => /^(((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)?$/ix

  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false
  validates_acceptance_of :eula, :on => :create, :allow_nil => false, :message => "must be abided"
  before_save :encrypt_password
  before_create :make_activation_code  

  # all string fields are filtered with strip_tags,
  # except the ones in ":except". fields in ":sanitize"
  # are run through sanitize, that uses the white-list
  # sanitizer configured in environment.rb 
  #
  xss_terminate :except => [:email, :msn, :gender, :photos_url, :blog_url, :myspace_url],
                :sanitize => [:motto, :tastes]
  
  has_many_friends
  
  # If type == 'Band'
  has_many :members, :class_name => 'BandMember'
  
  has_many :songs,            :order => 'songs.created_at DESC'
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
  
  # TODO 
  # aggiungere le seguenti relazioni:
  # 
  # * strumenti
  # * mband
  # * tracce
  # * annunci
  # * ammiratori
      
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :terms_of_service, :eula,
    :first_name, :last_name, :gender, :motto, :tastes, :country, :city, :age,
    :photos_url, :blog_url, :myspace_url, :skype, :msn, :skype_public, :msn_public    
  
  before_save :check_links
  
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
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] #find_by_login(login)
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
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def compiled_location
    (result = [city, country].compact.join(", ")).blank? ? "Unknown" : result
  end
  
  def self.find_coolest(options = {})
    self.find(:all, options.merge({:conditions => ["activated_at IS NOT NULL AND type IS NULL OR type = 'User'"], :order => 'rating_avg DESC', :limit => 9})) 
  end
  
  def self.find_coolest_band_or_deejays(options = {})
    self.find(:all, options.merge({:conditions => ["activated_at IS NOT NULL AND type = 'Band' or type = 'Dj'"], :order => 'rating_avg DESC', :limit => 9})) 
  end
  
  # TODO: stub sino a quando abbiamo i voti
  # Al momento si ritornano le canzoni per non avere utenti senza canzoni
  def self.find_best_myousicians(options)
    Song.find :random, options.merge({:conditions => "activated_at IS NOT NULL", :limit => 3, :include => [{:user => [:avatars, :songs]}]})
    #self.find(:all, options.merge({:conditions => "activated_at IS NOT NULL"}))
  end
  
  def self.find_prolific(options = {})
    qry = "SELECT users.*, songs.title, count(songs.id) AS songs_count FROM users LEFT JOIN songs ON users.id = songs.user_id WHERE (users.type = 'User' OR users.type IS NULL) AND users.activated_at IS NOT NULL AND songs.published = ? GROUP BY users.id ORDER BY songs_count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql([qry, true])
  end
  
  def self.find_prolific_band_or_deejays(options = {})
    qry = "SELECT users.*, songs.title, count(songs.id) AS songs_count FROM users LEFT JOIN songs ON users.id = songs.user_id WHERE (users.type = 'Band' OR users.type = 'Dj') AND users.activated_at IS NOT NULL AND songs.published = ? GROUP BY users.id ORDER BY songs_count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql([qry, true])
  end  
  
  def self.find_friendliest(options)
    # FIXME: This should be fixed to it loads the associated objects in a single query.
    self.find(:all, options.merge({:order => 'friends_count DESC', :conditions => 'users.activated_at IS NOT NULL'}))
  end
  
  # TODO: stub sino a quando abbiamo le band
  def self.find_most_banded(options)
    self.find(:all, options.merge(:conditions => 'activated_at IS NOT NULL'))
  end
  
  def self.find_newest(options)
    self.find(:all, options.merge({:order => 'created_at DESC', :conditions => 'activated_at IS NOT NULL'}))
  end
  
  # ATTENZIONE: METODO MOLTO COSTOSO
  def update_friends_count
    update_attribute(:friends_count, friends.size)
    friends.size
  end
  
  def friends_count
    @friends_count ||= (attributes[:friends_count] || update_friends_count)
  end
  
  def to_breadcrumb
    login
  end
  
  def instruments
    Instrument.find(:all, :include => [:tracks => [:parent_song => [:user]]], :conditions => ['user_id = ?', self.id])
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

  def find_admirers
    # FIXME: credo che gli ammiratori debbano essere solo quello che mi ammirano.
    self.pending_friends_for_me.find(:all, :include => :avatars) #+
    #self.pending_friends_by_me.find(:all, :include => :avatars)
  end
  
  # FIXME: da rendere più efficiente
  def self.find_with_more_instruments
    result = Instrument.count('description', :conditions => "users.type IS NULL OR users.type = 'User'", :include => [:tracks => [:parent_song => [:user]]], :group => 'user_id', :distinct => true, :order => 'count_description DESC')
    return result.first.is_a?(Array) ? User.find(result.first.first) : nil
  end
 
  def self.find_band_or_deejay_with_more_instruments
    result = Instrument.count('description', :conditions => "users.type = 'Band' OR users.type = 'Dj'", :include => [:tracks => [:parent_song => [:user]]], :group => 'user_id', :distinct => true, :order => 'count_description DESC')
    return result.first.is_a?(Array) ? User.find(result.first.first) : nil
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
