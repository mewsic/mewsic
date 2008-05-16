class MyousicaMailer < ActionMailer::Base

  def help(body, sent_at = Time.now)
    @subject    = 'Myousica Help Question'
    @body       = body
    @recipients = 'help@myousica.com'
    @from       = 'help@myousica.com'
    @sent_on    = sent_at
    @headers    = {}
  end
end
