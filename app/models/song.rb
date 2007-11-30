# == Schema Information
# Schema version: 5
#
# Table name: songs
#
#  id              :integer(11)   not null, primary key
#  title           :string(255)   
#  original_author :string(255)   
#  user_id         :integer(11)   
#  created_at      :datetime      
#  updated_at      :datetime      
#

class Song < ActiveRecord::Base
  has_many :tracks, :through => :mixes
  has_many :mixes
  has_many :children_tracks, :class_name => 'Track'

  belongs_to :genre
  belongs_to :user
  
  # TODO: STUB fino ai criteri di best
  def self.find_best(options = {})
    self.find(:all, options)
  end
end
