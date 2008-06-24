class AbuseMailer < ActionMailer::Base

  def notification(abuseable, sent_at = Time.now)
    @subject    = '[Myousica]'
    @body       = { :abuseable => abuseable }
    @recipients = 'abuse@myousica.com'
    @from       = 'no-reply@myousica.com'
    @sent_on    = sent_at
    @headers    = {}
  end
end
