# == Schema Information
# Schema version: 15
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
  
  def self.create_or_accept(user, friend)
    friendship = Friendship.find_by_user_id_and_friend_id(friend.id, user.id)
    if friendship
      friendship.update_attribute(:accepted_at, Time.now)
    else
      user.request_friendship_with(friend)
    end
  end
  
  def destroy_or_unaccept(user)
    if self.friendshipped_by_me == user
      self.destroy
    else
      self.update_attribute(:accepted_at, nil)
    end
  end
    
  protected  
  def fix_friends_count
    friendshipped_by_me.reload.update_friends_count
    friendshipped_for_me.reload.update_friends_count
  end  
end

