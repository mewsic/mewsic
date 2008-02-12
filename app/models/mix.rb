# == Schema Information
# Schema version: 10
#
# Table name: mixes
#
#  id         :integer(11)   not null, primary key
#  song_id    :integer(11)   
#  track_id   :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Mix < ActiveRecord::Base
  belongs_to :song
  belongs_to :track
end
