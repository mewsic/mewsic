# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# This observer adds two callbacks to the Friendship model, in order to send out private
# messages and e-mail notifications when new admiral or friendship relationships are
# established.
#
class FriendshipObserver < ActiveRecord::Observer
  # When created, a Friendship can only be an admiral relationship, because it has still
  # not been accepted by the recipient. This method sends out a message to the recipient
  # and an e-mail notification using UserMailer#admire_notification.
  #
  def after_create(friendship)
    sender, recipient = friendship.friendshipped_by_me, friendship.friendshipped_for_me

    return if recipient == User.myousica

    subject = "You have a new admirer: #{sender.login}!"
    body    = <<-EOM
<p><strong>#{sender.login}</strong> admires you.</p><p><br/></p>
<p>If you wanna become friends with #{sender.him}, you have to admire #{sender.login} back</p>
<p>from #{sender.his} page, by clicking on <a href="#{APPLICATION[:url]}/users/#{sender.to_param}">this link</a>.</p>
    EOM

    @message = Message.new(:subject => subject, :body => body)
    @message.sender = sender
    @message.recipient = recipient
    @message.save

    UserMailer.deliver_admire_notification(recipient, sender)
  end

  # This callback sends out a message and an e-mail notification when the friendship has
  # been accepted by the recipient. The Friendship is marked as established in the
  # Friendship#create_or_accept method.
  #
  def after_save(friendship)
    return unless friendship.established?

    # Two-way friendship has been established
    #
    sender, recipient = friendship.friendshipped_for_me, friendship.friendshipped_by_me
    subject = "You are now friends with #{sender.login}"
    body    = <<-EOM
<p><strong>Bravo!</strong></p>
<p>Myousician <a href="#{APPLICATION[:url]}/users/#{sender.to_param}">#{sender.login}</a> admires you too. You are now friends!</p>
    EOM

    @message = Message.new(:subject => subject, :body => body)
    @message.sender = sender
    @message.recipient = recipient
    @message.save

    UserMailer.deliver_friendship_notification(recipient, sender)
  end

end
