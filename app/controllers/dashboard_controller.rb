# Myousica Dashboard Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
# 
# This controller implements myousica home page, renders the Splash swf configuration and
# implements a pingback method for the Engine Yard monitoring software.
#
class DashboardController < ApplicationController
  
  before_filter :redirect_unless_xhr, :only => :top
  session :off, :only => :noop
  
  # <tt>GET /</tt>
  #
  # The home page contains banners, swf objects and a list of top myousicians
  #
  def index
    @people = User.find_top_myousicians :limit => 6
  end

  # <tt>XHR GET /top</tt>
  #
  # Returns a list of top myousicians, triggered when the user clicks the "refresh" button
  # in the "Top myousicians" section of the home page.
  #
  # Currently, random users are displayed, because as of 2008-10-03 we've got few users and
  # tracks, so the home page would have been too "static" (see http://adelao.lighthouseapp.com
  # /projects/10984/tickets/253 for more information). The commented out code will be restored
  # when enough users are on.
  #
  # See User#find_top_myousicians for the selection criteria.
  #
  def top
    @people = User.find_top_myousicians :limit => 6 #.sort_by{rand}.slice(0, 6).sort{|a,b|b.tracks_count.to_i <=> a.tracks_count.to_i}
    render :partial => 'myousician', :collection => @people
  end

  # <tt>GET /noop</tt>
  #
  # Pingback method, used by Engine Yard monitoring software. If passed an ID, it is echoed back.
  # Session is OFF in this method!
  #
  def noop
    if params[:id]
      render :text => params[:id].to_i
    else
      head :ok
    end
  end

  # <tt>GET /splash.xml</tt>
  #
  # Renders the splash configuration, finding the 5 most collaborated songs (see Song#find_most_collaborated).
  #
  def config
    @songs = Song.find_most_collaborated :limit => 5
    respond_to { |format| format.xml }
  end

  # <tt>GET /index/:origin</tt>
  #
  # Tracks a pageview coming from :origin, and sends it to google analytics.
  #
  def track
    @origin = params[:origin]
    redirect_to '/' and return unless %(yt fb).include? @origin
    render :layout => false
  end

private 

  # Filter to redirect to / if the request is not coming through XHR
  #
  def redirect_unless_xhr
    redirect_to '/' and return unless request.xhr?
  end
  
end
