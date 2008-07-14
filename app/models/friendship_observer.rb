class FriendshipObserver < ActiveRecord::Observer
  def after_create(friendship)
    return if friendship.friendshipped_for_me == User.myousica

    subject = "New friend request from #{friendship.friendshipped_by_me.login}"
    body    = %|
    <p>Your new admirer is #{friendship.friendshipped_by_me.login}.</p><p>To become friends you need to
    <a href="#{APPLICATION[:url]}/users/#{(friendship.friendshipped_by_me.to_param)}">go to his profile and admire him</a></p>
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = friendship.friendshipped_by_me
    @message.recipient = friendship.friendshipped_for_me
    @message.save
  end
  
  def after_destroy(friendship)
    subject = "Unfriend from #{friendship.friendshipped_by_me.login}"
    body    = %|
    <p><a href="#{APPLICATION[:url]}/users/#{(friendship.friendshipped_by_me.to_param)}">#{friendship.friendshipped_by_me.login}</a> has removed you from his friends.</p>
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = friendship.friendshipped_by_me
    @message.recipient = friendship.friendshipped_for_me
    @message.save
  end    
end
