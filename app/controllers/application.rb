# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '02cedf3882e78b5a99c0bec5cc75c3fc'
  
  include AuthenticatedSystem
  
  #before_filter :check_user_inbox
  before_filter :update_last_user_activity
  
  protected    
  
  def update_last_user_activity
    current_user.update_attribute(:last_activity_at, Time.now) if logged_in? && !request.xhr?
    #store_location unless logged_in? || controller_name == 'sessions'
  end

  def check_user_inbox
    if logged_in?
      if current_user.unread_message_count > 0
        flash.now[:inbox] = "You have <a href=\"#{user_path(current_user)}\">#{current_user.unread_message_count} unread messages</a>."
      end      
    end
  end
  
  def to_breadcrumb
    controller_name
  end    
    
  def valid_file_upload?(name)
    params[name] && params[name][:uploaded_data].respond_to?(:size) && params[name][:uploaded_data].size > 0
  end

  def check_valid_search_string
    @q = CGI::unescape(params[:q] || params[:id] || '')
    @q.gsub! /[%_]/, ''
    if @q.strip.blank?
      flash[:error] = 'You did not enter a search string' 
      respond_to do |format|
        format.html { redirect_to '/' and return }
        format.xml { render :nothing => true, :status => :bad_request }
      end
    end
  end

end
