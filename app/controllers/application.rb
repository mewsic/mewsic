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
    response.headers['X-Accel-Redirect']    = filename

    render :nothing => true
  end

end
