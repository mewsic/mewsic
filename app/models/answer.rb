# == Schema Information
# Schema version: 49
#
# Table name: answers
#
#  id               :integer(11)   not null, primary key
#  user_id          :integer(11)   
#  body             :text          
#  replies_count    :integer(11)   default(0)
#  created_at       :datetime      
#  updated_at       :datetime      
#  rating_count     :integer(11)   
#  rating_total     :decimal(10, 2 
#  rating_avg       :decimal(10, 2 
#  closed           :boolean(1)    not null
#  last_activity_at :datetime      
#

class Answer < ActiveRecord::Base
  
  # acts_as_sphinx
  #   extend SphinxWillPagination
  define_index do
  end
  
  has_many :replies, :order => 'created_at DESC', :dependent => :delete_all
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5 
  
  attr_accessible :body
  attr_readonly :replies_count
  
  has_many :abuses, :as => :abuseable
  
  validates_presence_of :body, :user_id
  validates_associated :user

  after_create :set_last_activity_at
  
  def self.find_open_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => ["answers.closed = ?", false],
                  :order => 'answers.created_at DESC, answers.rating_avg DESC',
                  :include => {:user => :avatars})
  end

  def self.find_top_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => "answers.rating_avg >= 3.0",
                  :order => 'answers.rating_avg DESC, answers.replies_count DESC',
                  :include => {:user => :avatars})
  end

  def self.top_count
    self.count :conditions => "answers.rating_avg >= 3.0"
  end

  def self.find_newest_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => ["answers.closed = ? AND answers.created_at > ?", false, 1.month.ago],
                  :order => 'answers.created_at DESC',
                  :include => {:user => :avatars})
  end

  def self.newest_count
    self.count :conditions => ["answers.closed = ? AND answers.created_at > ?", false, 1.month.ago]
  end

  def self.find_paginated_by_user(user, page, options = {})
    user.answers.paginate options.merge(:page => page, :order => 'answers.rating_avg DESC, created_at DESC') 
  end

  def self.find_newest(options = {})
    self.find(:all, options.merge(:order => 'answers.created_at DESC'))
  end

  def self.search_paginated(q, options)
    options = {:per_page => 6, :page => 1}.merge(options)
    self.paginate options.merge(:conditions => ["answers.body LIKE ?", "%#{q}%"],
                  :include => {:user => :avatars},
                  :order => 'answers.created_at DESC')
  end
  
  def self.close_old_answers
    update_all(["closed = ?", true], ["last_activity_at < ?", 1.month.ago])
  end

  def find_similar(per_page = 11)
    query = self.body.split.collect do |word|
      word.gsub! /[^\w]/, ''
      word if word.size > 3
    end.uniq.compact.join(' ')
    Answer.search(query, :per_page => per_page, :page => 1, :index => 'answers', :match_mode => :any)
  end

  def rateable_by?(user)
    self.user_id != user.id
  end

  def editable?
    created_at > 15.minutes.ago
  end

  def editable_for
    "%d minutes %d seconds" % ((self.created_at + 15.minutes) - Time.now).divmod(60) if editable?
  end

  def to_breadcrumb
    self.body[0..32] + '...'
  end
  
private

  def set_last_activity_at
    update_attribute(:last_activity_at, self.created_at)
  end
  
end
