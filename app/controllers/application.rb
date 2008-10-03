# Myousica Base Application Controller
#
# (C) 2008 Medlar s.r.l.
# (C) 2008 Mikamai s.r.l.
# (C) 2008 Adelao Group
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
      current_user.leave_multitrack! if current_user.multitrack? && !multitrack_request
    end

    store_location unless logged_in? || request.xhr? || multitrack_request || javascript_request || (controller_name == 'sessions') || (params[:format] == 'png') || (params[:format] == 'xml')
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

end
