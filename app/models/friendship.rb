# == Schema Information
# Schema version: 10
#
# Table name: friendships
#
#  id          :integer(11)   not null, primary key
#  user_id     :integer(11)   not null
#  friend_id   :integer(11)   not null
#  created_at  :datetime      
#  accepted_at :datetime      
#

class Friendship < ActiveRecord::Base

  belongs_to :friendshipped_by_me,   :foreign_key => "user_id",   :class_name => "User"
  belongs_to :friendshipped_for_me,  :foreign_key => "friend_id", :class_name => "User"

  # TODO: Add some friendly accessor methods here

  after_save :fix_friends_count
  after_destroy :fix_friends_count
    
  protected  
  def fix_friends_count
    friendshipped_by_me.reload.update_friends_count
    friendshipped_for_me.reload.update_friends_count
  end  
end

