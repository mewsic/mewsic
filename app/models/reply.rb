# == Schema Information
# Schema version: 14
#
# Table name: replies
#
#  id         :integer(11)   not null, primary key
#  answer_id  :integer(11)   
#  user_id    :integer(11)   
#  body       :text          
#  created_at :datetime      
#  updated_at :datetime      
#

class Reply < ActiveRecord::Base
  belongs_to :answer, :counter_cache => true
  belongs_to :user
  
  attr_accessible :body
  
  validates_presence_of :body
  
end
