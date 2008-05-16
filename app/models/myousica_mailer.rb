class MyousicaMailer < ActionMailer::Base

  def help(body, sent_at = Time.now)
    @subject    = 'MyousicaMailer#help'
    @body       = body
    @recipients = 'franz.andrea@gmail.com'
    @from       = 'help@myousica.com'
    @sent_on    = sent_at
    @headers    = {}
  end
end
