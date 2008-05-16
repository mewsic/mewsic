class HelpController < ApplicationController
  
  before_filter :find_pages
  
  def index    
  end
  
  def show
    @page = HelpPage.find(params[:id])    
  end

private

  def find_pages
    conditions = params[:id] ? ["help_pages.id != ?", params[:id]] : 1
    @help_pages = HelpPage.find(:all, :order => 'position ASC', :conditions => conditions)
  end
  
end
