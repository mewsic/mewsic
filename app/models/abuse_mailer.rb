class AbuseMailer < ActionMailer::Base

  def notification(abuseable, abuse, sender, sent_at = Time.now)
    @subject    = '[Myousica] Abuse notification'
    @body       = { :abuseable => abuseable, :abuse => abuse, :sender => sender }
    @recipients = 'abuse@myousica.com'
    @from       = 'no-reply@myousica.com'
    @sent_on    = sent_at
    @headers    = {}
  end
end
