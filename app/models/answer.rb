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
  
  validates_presence_of :body
  
  def self.find_newest(options = {})
    options.merge!({:order => 'answers.created_at desc'})
    self.find(:all, options)
  end
  
  def update_replies_count
    update_attribute(:replies_count, replies.count)
    replies.size
  end
end
