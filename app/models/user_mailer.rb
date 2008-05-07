class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = APPLICATION[:url] + "/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = APPLICATION[:url]
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = APPLICATION[:url] + "/account/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset'
  end
    
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Myousica <#{APPLICATION[:email]}>"
      @subject     = "[MYOUSICA] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
