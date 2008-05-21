class MbandMembershipObserver < ActiveRecord::Observer
  def after_create(membership)
    return if membership.mband.leader == membership.user
    #FIXME: fix link generation
    subject = "New mband invitation (#{membership.mband.name})"
    body    = %|
    Click <a href="#{APPLICATION[:url]}/mbands/#{membership.mband.id}">here</a> to view the mband profile.
    Click <a href="#{APPLICATION[:url]}/mband_memberships/accept/#{membership.membership_token}">here</a> to accept invitation.
    |
    @message = Message.new(:subject => subject, :body => body)
    @message.sender = membership.mband.leader
    @message.recipient = membership.user
    @message.save
  end
end