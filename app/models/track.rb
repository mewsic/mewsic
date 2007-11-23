# == Schema Information
# Schema version: 5
#
# Table name: tracks
#
#  id         :integer(11)   not null, primary key
#  title      :string(255)   
#  song_id    :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Track < ActiveRecord::Base
  has_many :songs, :through => :mixes
  has_many :mixes
  belongs_to :parent_song, :class_name => 'Song', :include => :user, :foreign_key => 'song_id'
  
  # FIXME: Per motivi di performance dovremmo tirare dentro anche gli users e la parent_song
  def self.find_most_used(options = {})
    Mix.count options.merge({:include => :track, :group => :track, :order => 'count_all DESC'}) 
  end
end
