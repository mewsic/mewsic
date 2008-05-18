class HelpController < ApplicationController
  
  before_filter :find_pages
  before_filter :create_help_request
  
  def index    
  end
  
  def show
    @page = HelpPage.find(params[:id])    
  end
  
  def send_mail
    redirect_to :action => 'index' and return unless request.post?

    if @request.valid?
      MyousicaMailer.deliver_help_request(@request)
      flash[:notice] = "Thanks for contacting us! Your question has been sent to our help desk, you'll receive a reply in few hours."
      params[:id] ? redirect_to(:action => 'show', :id => params[:id]) : redirect_to(:action => 'index')
    else
      flash.now[:error] = "Your help request could not be sent. Please correct the errors and try again!"
      params[:id] ? (show and render(:action => 'show')) : render(:action => 'index')
    end        
  end

private

  def find_pages
    conditions = params[:id] ? ["help_pages.id != ?", params[:id]] : 1
    @help_pages = HelpPage.find(:all, :order => 'position ASC', :conditions => conditions)
  end

  def create_help_request
    @request = HelpRequest.new(params[:help])
  end
  
end
