# == Schema Information
# Schema version: 14
#
# Table name: pictures
#
#  id               :integer(11)   not null, primary key
#  pictureable_id   :integer(11)   
#  pictureable_type :string(255)   
#  type             :string(255)   
#  size             :integer(11)   
#  content_type     :string(255)   
#  filename         :string(255)   
#  string           :string(255)   
#  thumbnail        :string(255)   
#  height           :integer(11)   
#  width            :integer(11)   
#  parent_id        :integer(11)   
#  created_at       :datetime      
#  updated_at       :datetime      
#

class Picture < ActiveRecord::Base
  belongs_to :pictureable, :polymorphic => true
end
