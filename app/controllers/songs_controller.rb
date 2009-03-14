# Myousica Songs controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller handles operations on Song objects.
#
class SongsController < ApplicationController
  
  before_filter :login_required, :only => [:update, :rate, :mix, :destroy, :confirm_destroy]
  before_filter :song_required, :only => [:load_track, :unload_track]
  before_filter :redirect_to_root_unless_xhr, :only => :confirm_destroy

  protect_from_forgery
  
  # ==== XHR GET /songs?[genre_id|user_id|mband_id]=ID
  # ==== GET /songs.xml?user_id=ID
  #
  # * HTML format: renders a paginated index of songs by User or Mband. Every
  #   model has its own template: <tt>{users,mbands}/_songs.html.erb</tt>.
  #   Song objects are returned by Song#find_paginated_by_user and Song#find_paginated_by_mband.
  # * XML format: returns an XML representation of the given user published songs.
  #
  def index
    respond_to do |format|
      format.html do
        redirect_to '/' and return unless request.xhr?

        @author =
          if params[:user_id]
            User.find_from_param(params[:user_id])
          elsif params[:mband_id]
            Mband.find_from_param(params[:mband_id])
          end

        @songs = @author.songs.published.with_tracks.paginate(:page => params[:page], :per_page => 3)

        render :layout => false
      end

      format.xml do
        @user = User.find_from_param(params[:user_id])
        @songs = @user.songs.published.with_tracks
      end
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
  
  # ==== GET /songs/:song_id
  # ==== GET /songs/:song_id.xml
  # ==== GET /songs/:song_id.png
  #
  # * HTML format: shows the song page
  # * XML format: shows the XML representation of the given song. Siblings (versions) info is included
  #   if the <tt>siblings</tt> param is present. Edit (volume & balance) info is included if the <tt>
  #   edit</tt> parameter is present.
  # * PNG format: streams the waveform png to the client using +x_accel_redirect+.
  #
  def show
    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }])        

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

        x_accel_redirect @song.public_filename(:waveform), :content_type => 'image/png'
      end
    end
  rescue ActiveRecord::RecordNotFound
    if params[:id].to_i.zero?
      head :ok
    else
      raise
    end
  end

  # ==== DELETE /songs/:id
  #
  # Tries to destroy the given Song instance. Because songs are used by tracks to inherit Genre
  # information, a Song with direct children tracks cannot be deleted. In this case, it is marked
  # as unpublished, its stream is removed and its mixes too.
  #
  # When a song has got no children tracks it is destroyed, and mixes are removed as a dependency.
  #
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

    flash[:notice] = "Song '#{@song.title}' has been deleted."

    head :ok

  rescue ActiveRecord::RecordNotFound # find
    head :not_found
  rescue ActiveRecord::ReadOnlyRecord # destroy
    head :bad_request
  rescue ActiveRecord::RecordNotSaved # save!
    head :forbidden
  end

  # ==== XHR GET /songs/:id/confirm_destroy
  #
  # Renders the <tt>_destroy.html.erb</tt> partial that asks the user confirmation
  # before deleting a Song.
  #
  def confirm_destroy
    @song = current_user.songs.find(params[:id])
    render :partial => 'destroy'
  end
  
  # ==== XHR GET /songs/:id/tracks
  #
  # Renders the <tt>_track.html.erb</tt> partial for every track in the given song.
  #
  def tracks
    render :nothing => true, :status => :bad_request and return unless request.xhr?

    @song = Song.find(params[:id], :include => [:user, { :mixes => { :track => [:instrument, :parent_song] } }, :genre])        
    render :layout => false, :partial => 'track', :collection => @song.tracks
  end


  # ==== PUT /songs/:id
  #
  # Updates the song record with the given parameters. An user can modify only
  # its own songs.
  # If updating a single attribute, this action renders the new value of it.
  # If updating multiple ones, nothing is rendered with a 200 status.
  #
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
  
  # ==== PUT /songs/:id/load_track
  #
  # This action is called by the multitrack SWF when adding a new track to the stage,
  # in order to reflect this addition into the database, by creating a new Mix with
  # the given track and updating the song length to the maximum length of its tracks.
  #
  # Nothing is rendered, the HTTP response code carries the result of the operation.
  #
  def load_track
    track = Track.find params[:track_id]

    @song.mixes.create :track => track
    @song.seconds = @song.mixes.find(:all).map { |m| m.track.seconds }.max
    @song.save!

    head :ok

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  # ==== PUT /songs/:id/unload_track
  #
  # This action is called by the multitrack SWF when removing a track from the stage,
  # in order to remove the associated Mix with the given track. Nothing is rendered,
  # the HTTP response code carries the result of the operation.
  # 
  def unload_track
    @song.mixes.find_by_track_id(params[:track_id]).destroy
    head :ok

  rescue NoMethodError
    head :not_found
  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  # ==== POST /songs/:id/mix
  #
  # This action is called by the multitrack SWF when saving a myousica project. Its
  # function is to create Mix object for every track added to the current project and
  # to save volume and balance information. Currently the SWF sends out some wrong
  # track IDs, which are ignored by this method.
  #
  # Upon success, the XML representation of a song is rendered. Upon failure, the
  # <tt>shared/_errors.xml.erb</tt> partial is rendered instead.
  #
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
  
  # ==== PUT /songs/:id/rate
  #
  # Rates a song, if Song#rateable_by? returns true, and prints the number of votes if successful.
  # If the Song isn't rateable by the current_user, nothing is rendered with a 400 status.
  #
  def rate    
    @song = Song.find(params[:id])
    if @song.rateable_by?(current_user)
      @song.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@song.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end       

  # ==== GET /songs/:id/download
  #
  # Streams the Song mp3 to the client, using +x_accel_redirect+ and by providing a nice title using
  # the song attributes: <tt>song.title</tt> and <tt>song.user.login</tt>.
  #
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
    x_accel_redirect @song.public_filename,
      :disposition => %[attachment; filename="#{@song.title} by #{@song.user.login}.mp3"],
      :content_type => 'audio/mpeg'

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Song not found'
    redirect_to music_path
  end
  
protected

  # Renders "Music" into the breadcrumb with a link to <tt>music_path</tt> (<tt>/music</tt>)
  #
  def to_breadcrumb_link
    ['Music', music_path]
  end

  # Tries to locate a song from the current user ones.
  # If no one is found, this request comes from an anonymous user, so send out a 404.
  #
  def song_required
    @song = 
      if logged_in?
        current_user.songs.find(params[:id])
      else
        Song.unpublished.find(params[:id])
      end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found
  end
end
