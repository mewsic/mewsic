# == Schema Information
# Schema version: 46
#
# Table name: mixes
#
#  id         :integer(11)   not null, primary key
#  song_id    :integer(11)   
#  track_id   :integer(11)   
#  volume     :float         default(1.0)
#  loop       :integer(11)   
#  balance    :float         default(0.0)
#  time_shift :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Mix < ActiveRecord::Base
  belongs_to :song
  belongs_to :track

  validates_presence_of :song_id
  validates_associated :song, :track

  validates_uniqueness_of :track_id, :scope => :song_id
end
