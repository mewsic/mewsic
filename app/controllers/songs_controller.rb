class SongsController < ApplicationController
  
  before_filter :login_required, :only => [:update, :rate]
  protect_from_forgery :except => [:mix, :update]
  
  def index
    respond_to do |format|
      format.html do
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
    @direct_siblings = @song.direct_siblings
    @indirect_siblings = @song.indirect_siblings
    respond_to do |format|
      format.html do
        @other_songs = Song.find(:all, :conditions => ["songs.user_id = ? AND songs.published = ?", @song.user, true], :order => 'songs.listened_times', :limit => 8, :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
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
        response.headers['X-Accel-Redirect'] = @song.filename.sub /\.mp3$/, '.png'

        render :nothing => true
      end
    end  
  end
  
  def direct_sibling_tracks
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    render :layout => false
  end
  
  def indirect_sibling_tracks
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    render :layout => false
  end
  
  def update
    @song = current_user.songs.find(params[:id])
    @song.update_attributes(params[:song])
    if params[:song].size == 1 && @song.respond_to?(params[:song].keys.first)
      if params[:song].keys.first == 'genre_id'
        render :text => @song.genre ? @song.genre.name : ''
      else
        render :text => @song.send(params[:song].keys.first)
      end
    else
      render :nothing => true
    end
  end
  
  def mix
    @song = current_user.songs.find(params[:id])

    tracks = params[:song].delete(:tracks) if params[:song][:tracks]
    tracks = [tracks] unless tracks.is_a?(Array)

    @song.published = true
    @song.update_attributes!(params[:song])

    #@song.mixes.clear
    tracks.each do |track|
      mix = Mix.new
      mix.song = @song
      mix.track_id = track[:id]
      mix.volume = track[:volume]
      mix.loop = track[:loop]
      mix.balance = track[:balance]
      mix.time_shift = track[:time_shift]
      mix.save!
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
    response.headers['Content-Disposition'] = %[attachment; filename="#{@song.title}"]
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
