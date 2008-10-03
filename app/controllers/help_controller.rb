# Myousica Help Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This simple controller handles the help section of the site. It displays an index page with
# all the help topics, shows the static help pages stored in the database and handles e-mail
# help requests using the MyousicaMailer.
#
class HelpController < ApplicationController
  
  before_filter :find_pages
  before_filter :create_help_request
  
  # <tt>GET /help</tt>
  #
  # Renders the help index page. See the +find_pages+ filter for details.
  #
  def index    
  end
  
  # <tt>GET /help/:help_page_id</tt>
  #
  # Renders a single help page, along with help topic list
  #
  def show
    @page = HelpPage.find_from_param(params[:id])    
  end
  
  # <tt>POST /help/ask</tt>
  #
  # Delivers an help request sent via the "Send Feedback" form on help pages, if it passes validation.
  #
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

  # Filter to find all the help pages, ordered by position. If an id has been passed, it is the
  # currently viewed page, which is ignored and not displayed in the listing.
  #
  def find_pages
    conditions = params[:id] ? ["help_pages.id != ?", params[:id]] : 1
    @help_pages = HelpPage.find(:all, :order => 'position ASC', :conditions => conditions)
  end

  # Filter that creates an help requests filled with the contents of the <tt>help</tt> parameter.
  #
  def create_help_request
    @help_request = HelpRequest.new(params[:help])
  end
  
end
