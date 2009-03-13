# == Schema Information
# Schema version: 20090312174538
#
# Table name: mixes
#
#  id         :integer(4)    not null, primary key
#  song_id    :integer(4)    
#  track_id   :integer(4)    
#  volume     :float         default(1.0)
#  loop       :integer(4)    
#  balance    :float         default(0.0)
#  time_shift :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
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
# == Description
#
# The Mix serves two purposes: associates tracks to songs, and it is the central concept of
# the song versioning system. See the Song#direct_siblings and Song#indirect_siblings methods
# for details.
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

  validates_presence_of :song_id
  validates_associated :song, :track

  validates_uniqueness_of :track_id, :scope => :song_id
end
