# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '02cedf3882e78b5a99c0bec5cc75c3fc'
  
  include AuthenticatedSystem
  
  before_filter :check_user_inbox
  
  protected    
  
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
    
end