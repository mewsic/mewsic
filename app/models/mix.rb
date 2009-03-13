# == Schema Information
# Schema version: 20090312174538
#
# Table name: mixes
#
#  id         :integer(4)    not null, primary key
#  song_id    :integer(4)    
#  track_id   :integer(4)    
#  volume     :float         default(1.0)
#  created_at :datetime      
#  updated_at :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# The Mix is the join model that associates tracks to songs, and contains the
# volume information for a track into a song.
#
# == Associations
#
# * <b>belongs_to</b> a Song
# * <b>belongs_to</b> a Track
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>song_id</tt>
# * <b>validates_associated</b> <tt>song</tt>, <tt>track</tt>
# * <b>validates_uniqueness_of</b> <tt>track_id</tt>, in the <tt>song_id</tt> scope.
#
class Mix < ActiveRecord::Base
  belongs_to :song
  belongs_to :track

  validates_presence_of :song_id, :track_id
  validates_associated :song, :track

  validates_uniqueness_of :track_id, :scope => :song_id
end
