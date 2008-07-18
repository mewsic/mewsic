# == Schema Information
# Schema version: 43
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
  has_many :replies, :order => 'created_at DESC'
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5 
  
  attr_accessible :body
  
  has_many :abuses, :as => :abuseable
  
  validates_presence_of :body

  after_create :set_last_activity_at
  
  def self.find_open_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => ["answers.closed = ?", false],
                  :order => 'answers.rating_avg DESC, answers.created_at DESC',
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

  ### XXX XXX FIXME !!! XXX
  def find_similar
    keywords = self.body.split(/ /).map! do |word|
      word.gsub! /[%_]/, ''
      next if word.length < 5
      "%#{word}%"
    end

    search_string = "answers.id != ? AND (" << Array.new(keywords.size).fill("answers.body LIKE ?").join(' OR ') << ")"
    
    Answer.find(:all, :include => {:user => :avatars}, :limit => 10, :order => 'answers.rating_avg DESC, answers.created_at DESC',
              :conditions => [search_string, self.id, *keywords])
  end

  def update_replies_count
    update_attribute(:replies_count, replies.count)
    replies.size
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
