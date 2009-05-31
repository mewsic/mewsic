class UserMailer < ActionMailer::Base
  helper :application

  def signup_notification(user)
    with_user_email_for(user) do
      @subject    << 'Welcome! Please activate your account'
    end
  end
  
  def activation(user)
    with_user_email_for(user) do
      @subject    << 'Your account has been activated!'
    end
  end
  
  def forgot_password(user)
    with_user_email_for(user) do
      @subject    << 'Request to change your password'
    end
  end

  def reset_password(user)
    with_user_email_for(user) do
      @subject    << 'Your password has been reset'
    end
  end

  def admire_notification(user, admirer)
    with_user_email_for(user) do
      @subject        << 'You have a new admirer!'
      @body[:admirer]  = admirer
    end
  end

  def friendship_notification(user, friend)
    with_user_email_for(user) do
      @subject       << "You are now friends with #{friend.login}"
      @body[:friend]  = friend
    end
  end

  def message_notification(message)
    with_user_email_for(message.recipient) do
      @subject       << "#{message.sender.login} has sent you a message!"
      @body[:message] = message
    end
  end

  def mband_invitation(membership)
    with_user_email_for(membership.user) do
      @subject       << 'M-band invitation!'
      @body[:user]    = membership.mband.leader
      @body[:mband]   = membership.mband
      @body[:token]   = membership.membership_token
    end
  end

  def collaboration_notification(recipient, song, tracks)
    with_user_email_for(recipient) do
      @subject    << %[ Bravo! "#{song.user.login}" has used your tracks in a new song! ]
      @body[:song] = song
      @body[:tracks] = tracks
    end
  end

  protected
    def with_user_email_for(user)
      @recipients     = "#{user.email}"
      @from           = "MEWSIC <#{APPLICATION[:email]}>"
      @subject        = "[MEWSIC] "
      @sent_on        = Time.now
      @body[:user]    = user
      @body[:subject] = @subject

      yield

      add_alternative_parts
    end

    def add_alternative_parts
      # infer template name from caller method name
      # this means that the method name must be the
      # same as the template name.
      template_name = caller[1].scan(/`(\w+)'/).flatten.first
      content_type 'multipart/related'

      part 'text/html' do |p|
        p.body render_message("#{template_name}.text.html.erb", @body)
      end

      part 'text/plain' do |p|
        p.body render_message("#{template_name}.text.plain.erb", @body)
      end

      #attachment 'image/png' do |a|
      #  a.body = File.read(File.join(RAILS_ROOT, 'public', 'images', 'logo.jpg'))
      #  a.content_disposition = 'inline'
      #  a.headers['Content-ID'] = '<logo>'
      #end
    end
end
