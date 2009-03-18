# This observer sends out a private message to the commentable object owner when a new
# comment is posted by an user. Messages are not sent out if the owner comments to its
# own objects.
#
class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    return unless comment.commentable.respond_to?(:user) # XXX FIXME REMOVE THIS, AND IMPLEMENT .members SUPPORT FOR MBANDS

    return if comment.commentable.user == comment.user

    subject = "#{comment.user.login} has posted a comment on your #{comment.commentable.class.human_name}"
    body    = %[
      <p>Click <a href="#{APPLICATION[:url]}/comments/#{comment.id}">here</a> to read #{comment.user.login}'s comment.</p>
    ]

    # XXX FIXME SEND OUT EMAIL
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = comment.user
    @message.recipient = comment.commentable.user
    @message.save
  end    
end
