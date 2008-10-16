# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# This is the mailer that sends out abuse notifications.
#
class AbuseMailer < ActionMailer::Base

  # Sends out an abuse notification to abuse@myousica.com from no-reply@myousica.com
  #
  # * <tt>abuseable</tt>: the abuseable object (currently, Song, Track, User or Answer)
  # * <tt>abuse</tt>: the abuse object
  # * <tt>sender</tt>: the abuse sender (see AbusesController#create)
  # * <tt>sent_at</tt>: the time to display in e-mail headers
  #
  def notification(abuseable, abuse, sender, sent_at = Time.now)
    @subject    = '[Myousica] Abuse notification'
    @body       = { :abuseable => abuseable, :abuse => abuse, :sender => sender }
    @recipients = 'abuse@myousica.com'
    @from       = 'no-reply@myousica.com'
    @sent_on    = sent_at
    @headers    = {}
  end
end
