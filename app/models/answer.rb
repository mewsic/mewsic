# == Schema Information
# Schema version: 14
#
# Table name: answers
#
#  id         :integer(11)   not null, primary key
#  user_id    :integer(11)   
#  body       :text          
#  created_at :datetime      
#  updated_at :datetime      
#

class Answer < ActiveRecord::Base
  has_many :replies, :order => 'created_at DESC'
  belongs_to :user
  
  attr_accessible :body
  
  validates_presence_of :body
  
  def self.find_newest(options = {})
    options.merge!({:order => 'answers.created_at desc'})
    self.find(:all, options)
  end
end
