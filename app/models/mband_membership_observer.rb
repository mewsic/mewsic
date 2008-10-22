# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# Observer for the MbandMembership model, only used to send out the "New Mband invitation" messages to users.
#
class MbandMembershipObserver < ActiveRecord::Observer

  # After creation of a membership, if it's not the leader one and has not been accepted yet,
  # sends out a private message and an e-mail to the <tt>membership.user</tt>. The sender is
  # the Mband's leader, and bodies contain links to accept or decline the membership using the
  # <tt>membership_token</tt> Mband attribute.
  #
  # The notification e-mail is sent using the UserMailer.
  #
  def after_create(membership)    
    return if membership.mband.leader == membership.user || !membership.accepted_at.nil?

    subject = "New M-mband invitation (#{membership.mband.name})"
    body    = <<-EOM
<p>Click <a href="#{APPLICATION[:url]}/mbands/#{membership.mband.to_param}">here</a> to view the mband profile.</p>
<p>Click <a href="#{APPLICATION[:url]}/mband_memberships/accept/#{membership.membership_token}">here</a> to accept the invitation.</p>
<p>Click <a href="#{APPLICATION[:url]}/mband_memberships/decline/#{membership.membership_token}">here</a> to decline the invitation.</p>
    EOM

    @message = Message.new(:subject => subject, :body => body)
    @message.sender = membership.mband.leader
    @message.recipient = membership.user
    @message.save

    UserMailer.deliver_mband_invitation(membership)
  end
end
