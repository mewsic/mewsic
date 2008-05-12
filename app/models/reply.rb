# == Schema Information
# Schema version: 15
#
# Table name: replies
#
#  id           :integer(11)   not null, primary key
#  answer_id    :integer(11)   
#  user_id      :integer(11)   
#  body         :text          
#  created_at   :datetime      
#  updated_at   :datetime      
#  rating_count :integer(11)   
#  rating_total :decimal(10, 2 
#  rating_avg   :decimal(10, 2 
#

class Reply < ActiveRecord::Base
  belongs_to :answer, :counter_cache => true
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5 
  
  attr_accessible :body
  
  validates_presence_of :body
  
end
