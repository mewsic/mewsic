class HelpController < ApplicationController
  
  before_filter :find_pages
  
  def index    
  end
  
  def show
    @page = HelpPage.find(params[:id])    
  end
  
  def send_mail   
    if params[:help] && !params[:help][:body].blank?
      mail = MyousicaMailer.create_help(params[:help][:body])
      MyousicaMailer.deliver(mail)
      flash[:notice] = "Mail has been sent correctly."
    else
      flash[:error] = "The question is required."
    end
    redirect_to :action => 'index'
  end

private

  def find_pages
    conditions = params[:id] ? ["help_pages.id != ?", params[:id]] : 1
    @help_pages = HelpPage.find(:all, :order => 'position ASC', :conditions => conditions)
  end
  
end
