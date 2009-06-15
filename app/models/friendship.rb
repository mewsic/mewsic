# == Schema Information
# Schema version: 20090614112927
#
# Table name: friendships
#
#  id          :integer(4)    not null, primary key
#  user_id     :integer(4)    not null
#  friend_id   :integer(4)    not null
#  created_at  :datetime      
#  accepted_at :datetime      
#

# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Schema Information
#
# Table name: friendships
#
#  id          :integer(11)   not null, primary key
#  user_id     :integer(11)   not null
#  friend_id   :integer(11)   not null
#  created_at  :datetime      
#  accepted_at :datetime      
#
# == Description
#
# This model represents a friendship between two users. The user that requested the 
# friendship is saved into <tt>user_id</tt>, the recipient of the request is saved
# into <tt>friend_id</tt> instead.
#
# When a friendship is requested by user A to user B, the former becomes an <b>admirer</b>
# of the latter. If user B then accepts the friendship, the <tt>accepted_at</tt> attribute
# is updated with the current time and the friendship becomes an established two-way one.
#
# If the initiator of the friendship then decides to break it, the Friendship object is
# destroyed and no relation exists between the two users. If the recipients breaks it
# instead, the initiator goes back to the <b>admirer</b> status.
#
# This model is used by the <tt>medlar_has_many_friends</tt> plugin that implements most of
# the friendly methods to manipulate friend lists.
# See https://ulisse.adelao.it/rdoc/myousica/plugins/medlar_has_many_friends/.
#
# == Associations
#
# * <b>belongs_to</b> <tt>friendshipped_by_me</tt> (<tt>user_id</tt>): the User that 
#   initiated this friendship.
# * <b>belongs_to</b> <tt>friendshipped_for_me</tt> (<tt>friend_id</tt>): the recipient
#   User of this friendship.
#
# == Validations
#
# * <b>validates_uniqueness_of</b> <tt>friend_id</tt>, in the <tt>user_id</tt> scope
# * <b>validates_uniqueness_of</b> <tt>user_id</tt>, in the <tt>friend_id</tt> scope
#
# == Callbacks
#
# * <b>after_save</b> +fix_friends_count+
# * <b>after_destroy</b> +fix_friends_count+
#
class Friendship < ActiveRecord::Base

  belongs_to :friendshipped_by_me,   :foreign_key => "user_id",   :class_name => "User"
  belongs_to :friendshipped_for_me,  :foreign_key => "friend_id", :class_name => "User"

  validates_uniqueness_of :friend_id, :scope => :user_id
  validates_uniqueness_of :user_id, :scope => :friend_id

  after_save :fix_friends_count
  after_destroy :fix_friends_count

  # Accessor to mark a two-way friendship that has just been established
  attr_accessor :established
  # Friendly accessor for the +established+ attribute
  alias :established? :established
  
  # Creates or accepts a friendship between <tt>user</tt> and <tt>friend</tt>.
  # If the friendship already exists, the <tt>accepted_at</tt> attribute is updated
  # with the current time and the <tt>established</tt> volatile attribute is set to
  # <tt>true</tt>, in order for the FriendshipObserver to send out an e-mail
  # notification to the recipient.
  #
  # If the friendship does not exist, it is created with the +request_friendship_with+
  # method.
  def self.create_or_accept(user, friend)
    friendship = Friendship.find_by_user_id_and_friend_id(friend.id, user.id)
    if friendship
      returning(friendship) do |f|
        f.established = true
        f.update_attribute(:accepted_at, Time.now)
      end
    else
      user.request_friendship_with(friend)
    end
  end

  # Destroys or unaccept a friendship between this user and the one passed as the first
  # parameter. If the initiator of the friendship is the given user, the friendship is
  # destroyed, otherwise the <tt>accepted_at</tt> attribute is set to <tt>nil</tt>, so
  # that the initiator becomes an <b>admirer</b> of the given user.
  def destroy_or_unaccept(user)
    if self.friendshipped_by_me == user
      self.destroy
    else
      self.update_attribute(:accepted_at, nil)
    end
  end
    
  protected
  # Updates the friends count both for the initiator and the recipient of the friendship,
  # using User#update_friends_count.
  def fix_friends_count
    friendshipped_by_me.reload.update_friends_count
    friendshipped_for_me.reload.update_friends_count
  end  
end

