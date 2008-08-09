# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # Show login page
  def new   
    @help_pages = HelpPage.find(:all, :order => 'position ASC') unless logged_in?
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
      redirect_back_or_default(user_url(current_user))
    else
      flash[:error] = "User not found or wrong password.."
      redirect_to login_path
    end
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

  def to_breadcrumb_link
    ['Log in', nil]
  end

end
