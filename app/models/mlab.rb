# == Schema Information
# Schema version: 41
#
# Table name: mlabs
#
#  id           :integer(11)   not null, primary key
#  user_id      :integer(11)   
#  mixable_id   :integer(11)   
#  mixable_type :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Mlab < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :mixable, :polymorphic => true
  
  validates_presence_of :mixable
  
end
