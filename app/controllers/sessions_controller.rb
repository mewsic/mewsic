# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # Show login page
  def new   
    @help_pages = HelpPage.find(:all, :order => 'position ASC') 
    redirect_to(user_url(current_user)) if logged_in?
  end

  # Log in
  def create
    redirect_url = '/'
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "Welcome back, #{self.current_user.login}!"
      redirect_url = user_url(current_user)
    else
      flash[:error] = "User not found or wrong password.."
    end
    redirect_back_or_default(redirect_url)
  end

  # Log out
  def destroy
    if logged_in?
      self.current_user.forget_me
      flash[:notice] = "You have been logged out"
    end

    cookies.delete :auth_token
    reset_session

    redirect_back_or_default('/')
  end
end
