# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# This observer sends out a private message to the answer owner when a new reply is posted
# by another user. Messages are not sent out if the owner replies.
#
class ReplyObserver < ActiveRecord::Observer
  def after_create(reply)
    return if reply.user == reply.answer.user

    subject = "New reply from #{reply.user.login}"
    body    = %|
    <p>Click <a href="#{APPLICATION[:url]}/answers/#{reply.answer.id}">here</a> to read #{reply.user.login}'s reply.</p>
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = reply.user
    @message.recipient = reply.answer.user
    @message.save
  end    
end
