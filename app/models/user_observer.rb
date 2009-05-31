class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
  end

  def after_save(user)  
    if user.pending?
      UserMailer.deliver_activation(user)
      #MyousicaMailer.deliver_new_user_notification(user)
    end

    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
    UserMailer.deliver_reset_password(user)  if user.recently_reset_password?
  end
end
