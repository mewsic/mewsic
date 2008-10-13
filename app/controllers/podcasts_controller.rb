class PodcastsController < ApplicationController
  def pcast
    @user = User.find_from_param params[:user_id]
    response.headers['Content-Type'] = 'application/octet-stream'

    respond_to do |format|
      format.xml
    end
  end

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
