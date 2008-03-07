# == Schema Information
# Schema version: 12
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
  belongs_to :answer
  belongs_to :user
end
