# == Schema Information
# Schema version: 10
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
  has_many :replies
  belongs_to :user
  
  def self.find_newest(options = {})
    options.merge({:order => 'created_at desc'})
    self.find(:all, options)
  end
end
