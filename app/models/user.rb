# == Schema Information
# Schema version: 10
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  remember_token            :string(255)   
#  activation_code           :string(255)   
#  country                   :string(255)   
#  city                      :string(255)   
#  first_name                :string(255)   
#  last_name                 :string(255)   
#  gender                    :string(255)   
#  photos_url                :string(255)   
#  blog_url                  :string(255)   
#  myspace_url               :string(255)   
#  skype                     :string(255)   
#  msn                       :string(255)   
#  msn_public                :boolean(1)    
#  skype_public              :boolean(1)    
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  type                      :string(255)   
#  motto                     :text          
#  tastes                    :text          
#  remember_token_expires_at :datetime      
#  activated_at              :datetime      
#  friends_count             :integer(11)   
#  age                       :integer(11)   
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
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_format_of       :email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false
  validates_acceptance_of :eula, :on => :create, :allow_nil => false, :message => "must be abided"
  before_save :encrypt_password
  before_create :make_activation_code  
  
  has_many_friends
  
  has_many :songs
  has_many :answers
  has_many :replies
  has_many :pictures
  
  acts_as_rated :rating_range => 0..5
  
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
  
  # TODO: è solo uno stub fino a quando decidiamo le caratteristiche dei coolest.
  def self.find_coolest(options)
    self.find(:all, options)
  end
  
  # TODO: stub sino a quando abbiamo i voti
  def self.find_best_myousicians(options)
    self.find(:all, options)
  end
  
  def self.find_prolific(options = {})
    qry = "SELECT users.*, songs.title, count(songs.id) AS songs_count FROM users LEFT JOIN songs ON users.id = songs.user_id GROUP BY users.id ORDER BY songs_count DESC"
    qry += " LIMIT #{options[:limit]}" if options.has_key?(:limit)
    User.find_by_sql(qry)
  end
  
  def self.find_friendliest(options)
    # FIXME: This should be fixed to it loads the associated objects in a single query.
    self.find :all, options.merge({:order => 'friends_count DESC'})
  end
  
  # TODO: stub sino a quando abbiamo le band
  def self.find_most_banded(options)
    self.find(:all, options)
  end
  
  def self.find_newest(options)
    self.find(:all, options.merge({:order => 'created_at DESC'}))
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
    Track.find_by_sql(["select DISTINCT T.instrument from users U, tracks T, songs S WHERE T.song_id = S.id AND S.user_id = U.id AND U.id = ?", self.id]).collect do |track|
      track.instrument
    end
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
    
end
