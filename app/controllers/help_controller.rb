class HelpController < ApplicationController
  
  before_filter :find_pages
  
  def index    
  end
  
  def show
    @page = HelpPage.find(params[:id])    
  end
  
  def send_mail   
    redirect_to :action => 'index' and return unless request.post?
    if params[:help] && !params[:help][:body].blank? && params[:help][:email] =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      mail = MyousicaMailer.create_help(params[:help][:body])
      MyousicaMailer.deliver(mail)
      flash[:notice] = "Your question has been sent to the help desk, you will receive a reply as soon as possible."
      params[:id] ? redirect_to(:action => 'show', :id => params[:id]) : redirect_to(:action => 'index')
    else
      flash[:error] = "Question is required and email address must be valid."
      params[:id] ? (show and render(:action => 'show')) : render(:action => 'index')
    end        
  end

private

  def find_pages
    conditions = params[:id] ? ["help_pages.id != ?", params[:id]] : 1
    @help_pages = HelpPage.find(:all, :order => 'position ASC', :conditions => conditions)
  end
  
end
