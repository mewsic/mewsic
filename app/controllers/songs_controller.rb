class SongsController < ApplicationController
  
  before_filter :login_required, :only => [:update, :rate]
  protect_from_forgery :except => [:mix]
  
  def index
    if params.has_key?("genre_id")
      @songs = Song.find_paginated_by_genre(params[:page], params[:genre_id])
      params[:id] = params[:genre_id]
    end
    if params.has_key?("user_id")
      @user = User.find(params[:user_id])
      @songs = Song.find_paginated_by_user(params[:page], params[:user_id])
      params[:id] = params[:user_id]
    end
    render :layout => false
  end
  
  def show
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    @direct_siblings = @song.direct_siblings
    respond_to do |format|
      format.html do
        @other_songs = Song.find(:all, :conditions => ["songs.id != ?", params[:id]], :limit => 5, :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
      end
      format.xml do
        @show_siblings  = params.include?(:siblings)
        @show_edit_info = params.include?(:edit) && params[:edit] == 'true'
      end
    end  
  end
  
  def direct_sibling_tracks
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    render :layout => false
  end
  
  def edit
    render :text => ''
  end
  
  def update
    @song = current_user.songs.find(params[:id])
    @song.update_attributes(params[:song])
    render :text => ''
  end
  
  def mix
    @song = current_user.songs.find(params[:id])
    song_params   = params[:song]        
    #tracks_params = song_params.delete(:tracks) if song_params[:tracks]
    tracks_params = song_params.delete(:track) if song_params[:track]
    tracks_params = [tracks_params] unless tracks_params.is_a?(Array)
    @song.published = true
    @song.save
    #@song.mixes.clear
    tracks_params.each do |track_params|
      mix = Mix.new
      mix.song = @song
      mix.track_id = track_params[:id]
      mix.volume = track_params[:volume]
      mix.loop = track_params[:loop]
      mix.balance = track_params[:balance]
      mix.time_shift = track_params[:time_shift]
      mix.save
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

  def download
    @song = Song.find(params[:id])
    if @song.filename.blank?
      flash[:error] = 'File not found'
      redirect_to song_path(@song) and return
    end

    # Requires the following nginx configuration:
    #  location /audio {
    #    root /data/myousica/shared/audio;
    #    internal;
    #  }
    response.headers['Content-Disposition'] = %[attachment; filename="#{@song.description}"]
    response.headers['Content-Type'] = 'audio/mpeg'
    response.headers['Cache-Control'] = 'private'
    response.headers['X-Accel-Redirect'] = @song.filename
    render :nothing => true

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Song not found'
    redirect_to music_path
  end
  
protected

  def to_breadcrumb_link
    ['Music', music_path]
  end

end
