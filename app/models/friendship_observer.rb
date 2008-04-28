class FriendshipObserver < ActiveRecord::Observer
  def after_create(friendship)
    #FIXME: fix link generation
    subject = "New friend request from #{friendship.friendshipped_by_me.login}"
    body    = %|
    Your new admirer is #{friendship.friendshipped_by_me.login}. To become friend you need to
    <a href="#{APPLICATION[:url]}/users/#{(friendship.friendshipped_by_me.id)}">go to his profile and admire him</a>
    
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = friendship.friendshipped_by_me
    @message.recipient = friendship.friendshipped_for_me
    @message.save
  end
  
  def after_destroy(friendship)
    #FIXME: fix link generation
    subject = "Unfriend from #{friendship.friendshipped_by_me.login}"
    body    = %|
    <a href="#{APPLICATION[:url]}/users/#{(friendship.friendshipped_by_me.id)}">#{friendship.friendshipped_by_me.login}</a> has removed you from his friends.            
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = friendship.friendshipped_by_me
    @message.recipient = friendship.friendshipped_for_me
    @message.save
  end    
end
