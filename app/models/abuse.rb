# == Schema Information
# Schema version: 35
#
# Table name: abuses
#
#  id             :integer(11)   not null, primary key
#  abuseable_id   :integer(11)   
#  abuseable_type :string(255)   
#  user_id        :integer(11)   
#  body           :text          
#  created_at     :datetime      
#  updated_at     :datetime      
#  topic          :string(255)   
#

class Abuse < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :abuseable, :polymorphic => true
  
end
