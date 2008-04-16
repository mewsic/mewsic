# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  def new    
  end

  def create
    redirect_url = params[:login_page] ? '/login' : '/'
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "Logged in successfully"
      redirect_url = user_url(current_user)
    else
      flash[:error] = "Not logged"
    end
    redirect_back_or_default(redirect_url)
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
