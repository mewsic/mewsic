# == Schema Information
# Schema version: 20090312174538
#
# Table name: answers
#
#  id               :integer(4)    not null, primary key
#  user_id          :integer(4)    
#  body             :text          
#  replies_count    :integer(4)    default(0)
#  created_at       :datetime      
#  updated_at       :datetime      
#  rating_count     :integer(4)    
#  rating_total     :decimal(10, 2 
#  rating_avg       :decimal(10, 2 
#  closed           :boolean(1)    not null
#  last_activity_at :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This model represents an Answer. The body field is indexed by sphinx and used for
# full-text searches. This model +acts_as_rated+, with a rating range from 0 to 5.
#
# An Answer can be open or closed, as saved in the <tt>closed</tt> attribute. Answer
# closing happens automatically when there are no replies in one month. Every time a
# Reply is added, the <tt>last_activity_at</tt> is updated keeping the Answer open.
#
# == Associations
#
# * <b>has_many</b> <tt>replies</tt>, ordered by creation time, and deleted all upon
#   destroy [Reply]
# * <b>has_many</b> <tt>abuses</tt>, polymorphic as <tt>abuseable</tt> [Abuse]
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>body</tt> and <tt>user_id</tt>
# * <b>validates_associated</b> <tt>user</tt>
#
# == Callbacks
#
# * <b>after_create</b> +set_last_activity_at+
#
class Answer < ActiveRecord::Base
  
  has_many :replies, :order => 'created_at DESC', :dependent => :delete_all
  has_many :abuses, :as => :abuseable
  belongs_to :user
  
  validates_presence_of :body, :user_id
  validates_associated :user

  after_create :set_last_activity_at

  acts_as_rated :rating_range => 0..5 

  attr_accessible :body
  attr_readonly :replies_count
  
  define_index do
    indexes :body
    #set_property :delta => true
  end

  # Finds open answers (whose have got the <tt>closed</tt> attribute to <tt>false</tt>)
  # and orders 'em by creation date and average rating. Eager-loads users and their
  # avatars. Paginated.
  def self.find_open_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => ["answers.closed = ?", false],
                  :order => 'answers.created_at DESC, answers.rating_avg DESC',
                  :include => {:user => :avatar})
  end

  # Finds top answers (whose rating average is >= 3.0) and orders 'em by rating average
  # and replies count. Eager-loads users and their avatars. Paginated.
  def self.find_top_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => "answers.rating_avg >= 3.0",
                  :order => 'answers.rating_avg DESC, answers.replies_count DESC',
                  :include => {:user => :avatar})
  end

  # Counts top answers, whose rating average is >= 3.0.
  def self.top_count
    self.count :conditions => "answers.rating_avg >= 3.0"
  end

  # Finds newest answers (whose are not <tt>closed</tt> and have been created in the
  # last month).
  def self.find_newest_paginated(page, options = {})
    self.paginate options.merge(:page => page,
                  :conditions => ["answers.closed = ? AND answers.created_at > ?", false, 1.month.ago],
                  :order => 'answers.created_at DESC',
                  :include => {:user => :avatar})
  end

  # Counts newest answers, whose are not <tt>closed</tt> and have been created in the
  # last month.
  def self.newest_count
    self.count :conditions => ["answers.closed = ? AND answers.created_at > ?", false, 1.month.ago]
  end

  # Finds an user answers, paginated and ordered by rating average and creation time.
  def self.find_paginated_by_user(user, page, options = {})
    user.answers.paginate options.merge(:page => page, :order => 'answers.rating_avg DESC, created_at DESC') 
  end

  # Finds newest answers, ordering 'em by creation time.
  def self.find_newest(options = {})
    self.find(:all, options.merge(:order => 'answers.created_at DESC'))
  end

  # Run by the cron daemon using <tt>script/runner</tt>: closes all answers that have get no activity
  # in the last month.
  def self.close_old_answers
    update_all(["closed = ?", true], ["last_activity_at < ?", 1.month.ago])
  end

  # Finds similar answers using full-text search. Similarity is achieved by searching all the body words
  # whose length is greater than 3 chars in the <tt>answers</tt> index.
  def find_similar(per_page = 11)
    query = self.body.split.collect do |word|
      word.gsub! /[^\w]/, ''
      word if word.size > 3
    end.uniq.compact.join(' ')
    Answer.search(query, :per_page => per_page, :page => 1, :index => 'answers', :match_mode => :any)
  end

  # Returns true if the answer is rateable by the passed user. Answers cannot be voted by their owner.
  def rateable_by?(user)
    self.user.rateable_by?(user)
  end

  # Returns true if the answer body is editable. Only answers created in the last 15 minutes are editable.
  def editable?
    created_at > 15.minutes.ago
  end

  # Prints out for how much time the answer will be editable
  def editable_for
    "%d minutes %d seconds" % ((self.created_at + 15.minutes) - Time.now).divmod(60) if editable?
  end

  # Passes the body to the breadcrumb helper (see +ApplicationHelper#breadcrumb+).
  def to_breadcrumb
    self.body
  end  

  # Sitemap priority for this instance
  # FIXME: This should change logaritmically using rating_avg
  def priority
    0.6
  end
  
private
  # sets <tt>last_activity_at</tt> to <tt>created_at</tt>
  #
  def set_last_activity_at
    update_attribute(:last_activity_at, self.created_at)
  end
  
end
