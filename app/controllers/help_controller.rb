class HelpController < ApplicationController
  
  before_filter :find_pages
  before_filter :create_help_request
  
  def index    
  end
  
  def show
    @page = HelpPage.find_from_param(params[:id])    
  end
  
  def ask
    if @help_request.valid?
      MyousicaMailer.deliver_help_request(@help_request)
      flash[:notice] = "Thanks for contacting us! Your question has been sent to our help desk, you'll receive a reply in few hours."
    else
      flash[:error] = "Your help request could not be sent. Please correct the errors and try again!"
    end        

    params[:return_to] ? redirect_to(:action => 'show', :id => params[:return_to]) : redirect_to(:action => 'index')
  end

protected
  def to_breadcrumb_link
    ['Myousica help', help_index_path]
  end

private

  def find_pages
    conditions = params[:id] ? ["help_pages.id != ?", params[:id]] : 1
    @help_pages = HelpPage.find(:all, :order => 'position ASC', :conditions => conditions)
  end

  def create_help_request
    @help_request = HelpRequest.new(params[:help])
  end
  
end
