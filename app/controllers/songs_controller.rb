class SongsController < ApplicationController
  
  before_filter :login_required, :only => [:update, :rate, :mix]
  before_filter :song_required, :only => [:load_track, :unload_track]

  protect_from_forgery
  
  def index
    respond_to do |format|
      format.html do
        redirect_to '/' and return unless request.xhr?

        if params.has_key?("genre_id")
          @genre = Genre.find_from_param(params[:genre_id])
          @songs = Song.find_paginated_by_genre(params[:page], @genre)
        elsif params.has_key?("user_id")
          @user = User.find_from_param(params[:user_id])
          @songs = Song.find_paginated_by_user(params[:page], @user)
        elsif params.has_key?("mband_id")
          @mband = Mband.find_from_param(params[:mband_id])
          @songs = Song.find_paginated_by_mband(params[:page], @mband)
        end

        render :layout => false
      end

      format.xml do
        render :text => 'invalid request', :status => :bad_request and return unless params[:user_id]

        user = User.find_from_param params[:user_id], :include => :songs
        @songs = user.songs.find_published
      end
    end
  end
  
  def show
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    if logged_in?
      @has_abuse = Abuse.exists?(["abuseable_type = 'Song' AND abuseable_id = ? AND user_id = ?", @song.id, current_user.id])
    end

    respond_to do |format|
      format.html

      format.xml do
        @show_siblings  = params.include?(:siblings)
        @show_edit_info = params.include?(:edit) && params[:edit] == 'true'
      end

      format.png do
        if @song.filename.blank?
          flash[:error] = 'file not found'
          redirect_to '/' and return
        end

        response.headers['Content-Disposition'] = 'inline'
        response.headers['Content-Type'] = 'image/png'
        response.headers['Cache-Control'] = 'private'
        response.headers['X-Accel-Redirect'] = @song.filename.sub /\.mp3$/, '.png'

        render :nothing => true
      end
    end  
  end
  
  def tracks
    render :nothing => true, :status => :bad_request and return unless request.xhr?

    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    render :layout => false, :partial => 'track', :collection => @song.tracks
  end

  def update
    @song = current_user.songs.find(params[:id])
    @song.update_attributes!(params[:song])
    @song.reload
    if params[:song].size == 1 && @song.respond_to?(params[:song].keys.first)
      if params[:song].keys.first == 'genre_id'
        render :text => @song.genre ? @song.genre.name : ''
      else
        render :text => @song.send(params[:song].keys.first)
      end
    else
      render :nothing => true, :status => :ok
    end

  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
  end
  
  def load_track
    track = Track.find params[:track_id]

    @song.mixes.create! :track => track
    @song.seconds = @song.mixes.find(:all).map { |m| m.track.seconds }.max
    @song.save!

    render :nothing => true, :status => :ok

  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
  end

  def unload_track
    @song.mixes.find_by_track_id(params[:track_id]).destroy
    render :nothing => true, :status => :ok

  rescue NoMethodError
    render :nothing => true, :status => :not_found
  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
  end

  def mix
    @song = current_user.songs.find(params[:id])
    tracks = params.delete(:tracks)
    render :nothing => true, :status => :bad_request and return if tracks.blank?

    Song.transaction do 
      if !@song.published
        # New song
        @song.published = true
      else
        # Existing song
        @song.mixes.clear
      end

      @song.update_attributes!(params[:song])
    
      tracks.each do |i, track|
        @song.mixes.create! :track_id => track[:id],
          :volume => track[:volume],
          :balance => track[:balance]
      end
    end

    respond_to do |format|
      format.xml do
        render :nothing => true, :status => :ok
      end
    end

  rescue ActiveRecord::ActiveRecordError
    render :partial => 'shared/errors', :object => @song.errors, :status => :bad_request
  end    
  
  def rate    
    @song = Song.find(params[:id])
    if @song.rateable_by?(current_user)
      @song.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@song.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
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
    response.headers['Content-Disposition'] = %[attachment; filename="#{@song.title} by #{@song.user.login}.mp3"]
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

  def song_required
    @song = 
      if logged_in?
        current_user.songs.find(params[:id])
      else
        Song.find_unpublished(params[:id])
      end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found
  end
end
