class SongsController < ApplicationController
  
  before_filter :login_required, :only => [:update, :rate]
  protect_from_forgery :except => [:update]
  
  def index
    if params.has_key?("genre_id")
      @songs = Song.find_paginated_by_genre(params[:page], params[:genre_id])
      params[:id] = params[:genre_id]
    end
    if params.has_key?("user_id")
      @songs = Song.find_paginated_by_user(params[:page], params[:user_id])
      params[:id] = params[:user_id]
    end
    render :layout => false
  end
  
  def show
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])
    @show_siblings  = params.include?(:siblings)
    @show_edit_info = params.include?(:edit) && params[:edit] == 'true'
    respond_to do |format|
      format.html
      format.xml
    end  
  end
  
  def edit
    render :text => ''
  end
  
  def update
    @song = current_user.songs.find(params[:id])
    song_params   = params[:song]    
    tracks_params = song_params.delete(:tracks) if song_params[:tracks]
    @song.update_attributes(song_params)

    tracks_params.each do |track_params|
      Mix.create(track_params.merge(:song => @song))
    end
    
    respond_to do |format|
      format.xml do
        render :xml => @song
      end
    end
  end
  
  def rate    
    @song = Song.find(params[:id])
    @song.rate(params[:rate].to_i, current_user)
    render :layout => false, :text => "#{@song.rating_count} votes"
  end
  
  def to_breadcrumb_link
    ['Music', music_path]
  end

end
