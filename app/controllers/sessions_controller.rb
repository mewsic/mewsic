# Myousica Sessions controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller handles the login/logout function of the site, and implements bare support
# for facebook connect.
#
class SessionsController < ApplicationController

  before_filter :check_facebook_request, :only => :connect
  
  # ==== GET /login
  #
  # Show login page.
  #
  def new   
    @help_pages = HelpPage.find(:all, :order => 'position ASC') unless logged_in?
    redirect_to(user_url(current_user)) if logged_in?
  end

  # ==== POST /sessions
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
      #forget_location if stored_location == root_path
      redirect_back_or_default(user_url(current_user))
    else
      flash[:error] = true
      redirect_to login_path
    end
  end

  # ==== GET /logout
  #
  # Log out
  #
  def destroy
    if logged_in?
      self.current_user.forget_me
      self.current_user = nil
      session[:fb_connect] = false
      cookies.delete :auth_token
      flash[:notice] = "You have been logged out"
    end

    redirect_back_or_default('/')
  end

  # === GET /connect
  #
  # Callback for the facebook connect service (http://connect.facebook.com)
  #
  def connect
    raise ArgumentError unless (params[:fname] == '_opener')
    raise ArgumentError unless connect = ActiveSupport::JSON.decode(params[:session])

    @user = User.find_by_facebook_uid(connect['uid'])

    if @user.nil?
      # create a new user for the Facebook User if not present
      @user = User.new
      @user.facebook_uid = connect['uid']

      # XXX  this is crap: login, country and email should be fetched from the facebook. Why?
      # because: login clashes could occur (if an user names itself fb_123456), the "unknown"
      # country is BAD design, because it's a corner case to cope with in views, and the fake
      # email is USELESS to send mewsic e-mail notifications to the user.
      #
      @user.login = "fb_#{@user.facebook_uid}"                 # XXX
      @user.country = "unknown"                                # XXX
      @user.email = "#{@user.facebook_uid}@users.facebook.com" # XXX

      @user.password = @user.password_confirmation = rand(2**32).to_s
      @user.save!
    end

    session[:fb_connect] = true
    self.current_user = @user

    # render the cross-domain communication channel
    render :layout => false

  rescue ActiveRecord::ActiveRecordError
    debugger
    head :forbidden

  rescue ArgumentError
    head :bad_request
  end

  def to_breadcrumb_link
    ['Log in', nil]
  end

  private
  def check_facebook_request
    # XXX TODO check that the request is actually coming from facebook.
  end

end
