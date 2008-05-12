# == Schema Information
# Schema version: 15
#
# Table name: ratings
#
#  id         :integer(11)   not null, primary key
#  rater_id   :integer(11)   
#  rated_id   :integer(11)   
#  rated_type :string(255)   
#  rating     :decimal(10, 2 
#

class Rating < ActiveRecord::Base
  belongs_to :rated, :polymorphic => true
  belongs_to :rater, :class_name => 'User', :foreign_key => :rater_id
end
