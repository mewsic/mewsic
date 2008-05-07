# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '02cedf3882e78b5a99c0bec5cc75c3fc'
  
  include AuthenticatedSystem
      
  protected    
  
  def to_breadcrumb
    controller_name
  end    
   
  def local_request?
    false    
  end
    
end