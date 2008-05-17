class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Welcome! Please activate your account'
    @body[:url]  = APPLICATION[:url] + "/activate/#{user.activation_code}"

    add_alternative_parts 'signup_notification'
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = APPLICATION[:url]

    add_alternative_parts 'activation'
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = APPLICATION[:url] + "/reset_password/#{user.password_reset_code}" 

    add_alternative_parts 'forgot_password'
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset'

    add_alternative_parts 'reset_password'
  end
    
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Myousica <#{APPLICATION[:email]}>"
      @subject     = "[MYOUSICA] "
      @sent_on     = Time.now
      @body[:user] = user
    end

    def add_alternative_parts(template_name)
      content_type 'multipart/related'

      part 'text/html' do |p|
        p.body render_message("#{template_name}.text.html.erb", @body)
      end

      part 'text/plain' do |p|
        p.body render_message("#{template_name}.text.plain.erb", @body)
      end

      attachment 'image/png' do |a|
        a.body = File.read(File.join(RAILS_ROOT, 'public', 'images', 'logo_myousica.png'))
        a.content_disposition = 'inline'
        a.headers['Content-ID'] = '<logo_myousica>'
      end
    end
end
