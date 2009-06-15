# == Schema Information
# Schema version: 20090615124539
#
# Table name: featurings
#
#  id         :integer(4)    not null, primary key
#  song_id    :integer(4)    
#  user_id    :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class Featuring < ActiveRecord::Base
  belongs_to :song
  belongs_to :user
end
