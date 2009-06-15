# == Schema Information
# Schema version: 20090614112927
#
# Table name: mlabs
#
#  id           :integer(4)    not null, primary key
#  user_id      :integer(4)    
#  mixable_id   :integer(4)    
#  mixable_type :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# An Mlab is an element into an User's Playlist. Because it is persistent upon sessions,
# it is stored into the database.
#
# == Associations and validations
#
# Belongs to an User and to a <tt>mixable</tt> object, that can be either a Song or a Track.
# Validates the presence of the <tt>mixable</tt> and the <tt>user_id</tt>.
#
class Mlab < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :mixable, :polymorphic => true
  
  validates_presence_of :mixable, :user_id

  named_scope :tracks, :conditions => "mlabs.mixable_type = 'Track'"
  named_scope :songs, :conditions => "mlabs.mixable_type = 'Song'"

  def self.items_for(user)
    user.mlabs.songs + user.mlabs.tracks
  end

end
