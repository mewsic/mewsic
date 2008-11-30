# Myousica Podcasts controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This simple controller generates users' and mbands' podcasts.
#
class PodcastsController < ApplicationController
  session :off

  # ==== GET /users/:user_id/:user_id.pcast
  #
  # Renders the very simple pcast format that describes iTunes where to find
  # a specific podcast. Useful only for Windows clients.
  #
  def pcast
    @user = User.find_from_param params[:user_id]
    response.headers['Content-Type'] = 'application/octet-stream'

    respond_to do |format|
      format.xml
    end
  end

  # ==== GET /users/:user_id/podcast.xml
  # ==== GET /mbands/:mband_id/podcast.xml
  #
  # Generates an user or an mband's podcast with current published songs.
  # Renders nothing with a 403 status if the podcast is not marked as public
  # in the user preferences.
  #
  def show
    if params[:user_id]
      template = 'user_podcast'
      @user = User.find_from_param params[:user_id]
      head :forbidden and return unless @user.podcast_public?
      @songs = @user.published_songs
    elsif params[:mband_id]
      template = 'mband_podcast'
      @mband = Mband.find_from_param params[:mband_id]
      @songs = @mband.published_songs
    else
      raise ActiveRecord::RecordNotFound
    end

    respond_to do |format|
      format.xml { render :action => template }
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found and return
  end
end
