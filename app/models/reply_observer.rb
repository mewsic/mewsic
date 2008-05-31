class ReplyObserver < ActiveRecord::Observer
  def after_create(reply)
    return if reply.user == reply.answer.user
    #FIXME: fix link generation
    subject = "New reply from #{reply.user.login}"
    body    = %|
    <p>Click <a href="#{APPLICATION[:url]}/answers/#{reply.answer.id}>here</a> to read #{reply.user.login}'s reply.</p>
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = reply.user
    @message.recipient = reply.answer.user
    @message.save
  end    
end
