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
  
  session :off, :only => :noop
  
  # ==== GET /
  #
  # The home page contains banners, swf objects and a list of top myousicians
  #
  def index
    @best_musicians = User.find_top_musicians :limit => 4
    @newest_mbands = Mband.find_newest :limit => 4
    @newest_songs = Song.find_newest :limit => 3
    @top_tags = Tag.find_top :limit => 20

    #@pick_of_the_week = User.find_pick_of_the_week, :include => [:photos, :videos, :songs]
    #@knowledge_items = Knowledge.find_top_rated

    @origin = params[:origin] # For landing pages

    respond_to { |format| format.html }
  end

  # ==== GET /noop
  #
  # Pingback method, used by monitoring software. If passed an ID, it is echoed back.
  # Session is OFF in this method!
  #
  def noop
    if params[:id]
      render :text => params[:id].to_i
    else
      head :ok
    end
  end

end
