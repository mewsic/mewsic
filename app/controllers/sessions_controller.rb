# Myousica Sessions controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller handles the login/logout function of the site.  
#
class SessionsController < ApplicationController

  # <tt>GET /login</tt>
  #
  # Show login page.
  #
  def new   
    @help_pages = HelpPage.find(:all, :order => 'position ASC') unless logged_in?
    redirect_to(user_url(current_user)) if logged_in?
  end

  # <tt>POST /sessions</tt>
  #
  # Log in
  #
  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "Welcome back, #{self.current_user.login}!"
      forget_location if stored_location == root_path
      redirect_back_or_default(user_url(current_user))
    else
      flash[:error] = "User not found or wrong password.."
      redirect_to login_path
    end
  end

  # <tt>GET /logout</tt>
  #
  # Log out
  #
  def destroy
    if logged_in?
      self.current_user.forget_me
      self.current_user = nil
      cookies.delete :auth_token
      flash[:notice] = "You have been logged out"
    end

    redirect_back_or_default('/')
  end

  def to_breadcrumb_link
    ['Log in', nil]
  end

end
