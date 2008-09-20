class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user)

    if User.myousica
      Friendship.create! :user_id => user.id, :friend_id => User.myousica.id, :accepted_at => Time.now
    end
  end

  def after_save(user)  
    if user.pending?
      UserMailer.deliver_activation(user)
      MyousicaMailer.deliver_new_user_notification(user)
    end

    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
    UserMailer.deliver_reset_password(user)  if user.recently_reset_password?
  end
end
