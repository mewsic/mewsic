# Myousica Base Application Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#
class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  
  helper :all # include all helpers, all the time
  protect_from_forgery
  
  include AuthenticatedSystem
  
  #before_filter :check_user_inbox
  before_filter :update_user_status
  before_filter :set_tracking_cookie
  before_filter :sso_via_facebook_connect_cookie
  
protected    
  
  # Updates the <tt>status</tt> attribute of the current user record to implement the online/offline/recording
  # tristate that indicates user status on the site.
  #
  # If an user is not logged in, this method only stores the current location in the session to bring the user
  # back to it upon login.
  # 
  # The location is not stored for many kinds of requests: XHR, multitrack, javascript, png and XML. It's also
  # not stored if the user interacts with the SessionsController, because it serves only log in pages.
  #
  def update_user_status
    multitrack_request = request.env['HTTP_REFERER'] && request.env['HTTP_REFERER'] =~ /\/multitrack/i
    javascript_request = params[:format] == 'js'

    if logged_in? && !request.xhr?
      current_user.update_attribute(:status, multitrack_request ? 'rec' : 'on')
      #current_user.leave_multitrack! if current_user.multitrack? && !multitrack_request
    end

    store_location unless logged_in? || request.xhr? || multitrack_request || javascript_request || (controller_name == 'sessions') || (params[:format] == 'png') || (params[:format] == 'xml')
  end

  def set_tracking_cookie
    unless cookies[:__mt]
      @tracked_user = cookies[:__mt] = "#{rand(2**24)}.#{Time.now.to_f}"
    end
  end

  def tracked_user
    cookies[:__mt] || @tracked_user
  end

  # Reference: Verifying the Signature on the Facebook developers wiki
  # http://wiki.developers.facebook.com/index.php/Verifying_The_Signature#Signatures_and_Facebook_Connect_Sites
  require 'digest/md5'
  FB_api_key    = '8b03aa5c7dae2e65e155bdcd41634d25' # XXX MOVE ME ELSEWHERE
  FB_secret_key = '7f46738b08178dcdefea905d677a91d1'
  def sso_via_facebook_connect_cookie
    # Check that all cookies are present, and log out if previously logged in via connect.
    #
    unless fb_sig_cookie && %w(user session_key expires ss).all? { |id| fb_sig_cookie(id) }
      if session[:fb_connect]
        self.current_user = nil
        session[:fb_connect] = false
      end
      return
    end

    # Obivously don't attempt to do SSO if the user is still logged in.
    #
    return if logged_in?
    
    # Calculate the expected signature
    #
    expected_sig = Digest::MD5.hexdigest([
      :expires=,     fb_sig_cookie(:expires),
      :session_key=, fb_sig_cookie(:session_key),
      :ss=,          fb_sig_cookie(:ss),
      :user=,        fb_sig_cookie(:user),
      FB_secret_key
    ].join)

    if expected_sig == fb_sig_cookie
      # Match! Check for a facebook user with this UID and log in if it's present
      self.current_user = User.find_by_facebook_uid(fb_sig_cookie(:user))
      session[:fb_connect] = true
    else
      # Kick off the attacker's ass out from here.
      %w(user session_key expires ss).each { |id| cookies.delete(fb_sig_cookie_name(id)) }
      cookies.delete(fb_sig_cookie_name)
    end

  end

  def fb_sig_cookie(id = nil)
    cookies[fb_sig_cookie_name(id)]
  end

  def fb_sig_cookie_name(id = nil)
    name = FB_api_key
    name += '_' + id.to_s if id
    name
  end

  #def check_user_inbox
  #  if logged_in?
  #    if current_user.unread_message_count > 0
  #      flash.now[:inbox] = "You have <a href=\"#{user_path(current_user)}\">#{current_user.unread_message_count} unread messages</a>."
  #    end      
  #  end
  #end
  
  # Generic to_breadcrumb method for controllers, which sends out the human controller name. Overriden in many controllers.
  # See the ApplicationHelper#breadcrumb method for more information.
  #
  def to_breadcrumb
    controller_name
  end    
    
  # Utility method to check for valid file uploads, it checks if the file exists and it has a size greater than 0.
  #
  def valid_file_upload?(name)
    params[name] && params[name][:uploaded_data].respond_to?(:size) && params[name][:uploaded_data].size > 0
  end

  # Utility method that redirects to the root path unless the request comes through XHR
  #
  def redirect_to_root_unless_xhr
    redirect_to root_path unless request.xhr?
  end

  # Utility method that sends out an X-Accel-Redirect header for nginx. The web server then starts uploading
  # the file to the client, leaving the mongrel free to process another request. <tt>send_file</tt> is evil.
  #
  def x_accel_redirect(filename, options = {})
    options.reverse_update(
      :disposition => 'inline',
      :content_type => 'application/octet-stream',
      :cache_control => 'private')

    response.headers['Content-Disposition'] = options[:disposition]
    response.headers['Content-Type']        = options[:content_type]
    response.headers['Cache-Control']       = options[:cache_control]

    case request.server_software
    when /apache/
      response.headers['X-Sendfile']          = File.join(RAILS_ROOT, 'public', filename)
      head :ok
    when /nginx/
      response.headers['X-Accel-Redirect']    = filename
      head :ok
    else
      send_file File.join(RAILS_ROOT, 'public', filename),
        :type => options[:content_type], :disposition => options[:disposition]
    end
  end

  # Utility method to check whether the current request comes from a Googlebot
  #
  def googlebot?
    request.user_agent.downcase =~ /googlebot/
  end

end
