# == Schema Information
# Schema version: 9
#
# Table name: songs
#
#  id              :integer(11)   not null, primary key
#  title           :string(255)   
#  original_author :string(255)   
#  user_id         :integer(11)   
#  genre_id        :integer(11)   
#  created_at      :datetime      
#  updated_at      :datetime      
#  rating_count    :integer(11)   
#  rating_total    :decimal(10, 2 
#  rating_avg      :decimal(10, 2 
#

class Song < ActiveRecord::Base
  has_many :tracks, :through => :mixes
  has_many :mixes
  has_many :children_tracks, :class_name => 'Track'

  belongs_to :genre
  belongs_to :user
  
  acts_as_rated :rating_range => 0..5
  
  # TODO: STUB fino ai criteri di best
  def self.find_best(options = {})
    self.find(:all, options)
  end
  
  def self.find_newest(options = {})
    options.merge({:order => 'created_at desc'})
    self.find(:all, options)
  end
end
