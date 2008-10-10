class MbandMembershipObserver < ActiveRecord::Observer
  def after_create(membership)    
    return if membership.mband.leader == membership.user || !membership.accepted_at.nil?

    subject = "New M-mband invitation (#{membership.mband.name})"
    body    = <<-EOM
<p>Click <a href="#{APPLICATION[:url]}/mbands/#{membership.mband.to_param}">here</a> to view the mband profile.</p>
<p>Click <a href="#{APPLICATION[:url]}/mband_memberships/accept/#{membership.membership_token}">here</a> to accept the invitation.</p>
<p>Click <a href="#{APPLICATION[:url]}/mband_memberships/decline/#{membership.id}">here</a> to decline the invitation.</p>
    EOM

    @message = Message.new(:subject => subject, :body => body)
    @message.sender = membership.mband.leader
    @message.recipient = membership.user
    @message.save

    UserMailer.deliver_mband_invitation(membership)
  end
end
