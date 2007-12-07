# == Schema Information
# Schema version: 9
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
end
