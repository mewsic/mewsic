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
  
  before_filter :redirect_to_root_unless_xhr, :only => :top
  before_filter :find_top_myousicians, :only => [:index, :top, :track]
  session :off, :only => :noop
  
  # <tt>GET /</tt>
  #
  # The home page contains banners, swf objects and a list of top myousicians
  #
  def index
    respond_to { |format| format.html }
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
    render :partial => 'myousician', :collection => @people
  end

  # <tt>GET /index/:origin</tt>
  #
  # Tracks a pageview coming from :origin, and sends it to google analytics.
  # This action renders the home page.
  #
  def track
    redirect_to '/' and return unless %(yt fb).include? params[:origin]
    @landing_origin = "landing_#{params[:origin]}"
    render :action => 'index'
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

private 

  # Filter that finds the top myousicians to display in the home page
  #
  def find_top_myousicians
    @people = User.find_top_myousicians :limit => 6 #.sort_by{rand}.slice(0, 6).sort{|a,b|b.tracks_count.to_i <=> a.tracks_count.to_i}
  end
  
end
