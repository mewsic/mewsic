# == Schema Information
# Schema version: 26
#
# Table name: answers
#
#  id            :integer(11)   not null, primary key
#  user_id       :integer(11)   
#  body          :text          
#  replies_count :integer(11)   default(0)
#  created_at    :datetime      
#  updated_at    :datetime      
#  rating_count  :integer(11)   
#  rating_total  :decimal(10, 2 
#  rating_avg    :decimal(10, 2 
#

class Answer < ActiveRecord::Base
  has_many :replies, :order => 'created_at DESC'
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5 
  
  attr_accessible :body
  
  has_many :abuses, :as => :abuseable
  
  validates_presence_of :body

  after_create :set_last_activity_at
  
  def self.find_newest(options = {})
    options.merge!({:order => 'answers.created_at desc'})
    self.find(:all, options)
  end
  
  def self.close_old_answers
    update_all(["closed = ?", true], ["last_activity_at < ?", 1.month.ago])
  end
  
  def update_replies_count
    update_attribute(:replies_count, replies.count)
    replies.size
  end  
  
private

  def set_last_activity_at
    update_attribute(:last_activity_at, self.created_at)
  end
  
end
