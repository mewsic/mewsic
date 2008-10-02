class SongsController < ApplicationController
  
  before_filter :login_required, :only => [:update, :rate, :mix, :destroy, :confirm_destroy]
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
          @songs = Song.find_paginated_by_user(params[:page], @user, :skip_blank => current_user != @user)
        elsif params.has_key?("mband_id")
          @mband = Mband.find_from_param(params[:mband_id])
          @songs = Song.find_paginated_by_mband(params[:page], @mband, :skip_blank => !@mband.band_membership_with(current_user))
        end

        render :layout => false
      end

      format.xml do
        @user = User.find_from_param(params[:user_id])
        @songs = @user.songs.find_published
      end
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
  
  def show
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        

    respond_to do |format|
      format.html do
        if logged_in?
          @has_abuse = Abuse.exists?(["abuseable_type = 'Song' AND abuseable_id = ? AND user_id = ?", @song.id, current_user.id])
        end
      end

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
        response.headers['X-Accel-Redirect'] = @song.public_filename :waveform

        render :nothing => true
      end
    end
  rescue ActiveRecord::RecordNotFound
    if params[:id].to_i.zero?
      head :ok
    else
      raise
    end
  end

  def destroy
    @song = current_user.songs.find(params[:id])
    if @song.children_tracks.count > 0
      @song.published = false
      @song.remove_stream
      @song.mixes.clear
      @song.save!
    else
      @song.destroy
    end

    flash[:notice] = "Song ##{@song.id} has been deleted." unless request.xhr?

    head :ok

  rescue ActiveRecord::RecordNotFound # find
    head :not_found
  rescue ActiveRecord::ReadOnlyRecord # destroy
    head :bad_request
  rescue ActiveRecord::RecordNotSaved # save!
    head :forbidden
  end

  def confirm_destroy
    redirect_to root_path and return unless request.xhr?
    @song = current_user.songs.find(params[:id])
    render :partial => 'destroy'
  end
  
  def tracks
    render :nothing => true, :status => :bad_request and return unless request.xhr?

    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    render :layout => false, :partial => 'track', :collection => @song.tracks
  end

  def pcast
    @user = User.find_from_param params[:user_id]
    response.headers['Content-Type'] = 'application/octet-stream'

    respond_to do |format|
      format.xml
    end
  end

  def podcast
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
      format.xml { render :template => "songs/#{template}" }
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found and return
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
      head :ok
    end

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end
  
  def load_track
    track = Track.find params[:track_id]

    @song.mixes.create :track => track
    @song.seconds = @song.mixes.find(:all).map { |m| m.track.seconds }.max
    @song.save!

    head :ok

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  def unload_track
    @song.mixes.find_by_track_id(params[:track_id]).destroy
    head :ok

  rescue NoMethodError
    head :not_found
  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  def mix
    @song = current_user.songs.find(params[:id])
    tracks = params.delete(:tracks)
    head :bad_request and return if tracks.blank?

    Song.transaction do 
      @song.mixes.clear
      #@song.update_attributes!(params[:song])
    
      tracks.each do |i, track|
        next if track['filename'].blank? || !Track.exists?(['id = ?', track['id']])
        @song.mixes.create! :track_id => track['id'],
          :volume => track['volume'],
          :balance => track['balance']
      end
      @song.save!
    end

    respond_to do |format|
      format.xml do
        render :partial => 'shared/song', :object => @song
      end
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found

  rescue ActiveRecord::ActiveRecordError
    respond_to do |format|
      format.xml do
        render :partial => 'shared/errors', :object => @song.errors, :status => :bad_request
      end
    end
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
    response.headers['X-Accel-Redirect'] = @song.public_filename
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
