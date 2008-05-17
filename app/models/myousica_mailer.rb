class MyousicaMailer < ActionMailer::Base

  def help_request(request, sent_at = Time.now)
    @subject    = 'Myousica Help Question'
    @body       = request.body
    @recipients = 'help@myousica.com'
    @from       = request.email
    @sent_on    = sent_at
    @headers    = {}
  end
end
