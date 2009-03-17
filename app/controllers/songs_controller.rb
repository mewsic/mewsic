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
  before_filter :writable_song_required, :only => [:update, :mix]
  before_filter :redirect_to_root_unless_xhr, :only => :confirm_destroy

  protect_from_forgery
  
  # ==== XHR GET /songs?[user_id|mband_id]=ID
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
  # * XML format: shows the XML representation of the given song.
  # * PNG format: streams the waveform png to the client using +x_accel_redirect+.
  #
  def show
    @song = Song.find(params[:id], :include => [:user, {:mixes => {:track => :instrument}}])

    respond_to do |format|

      format.html do
        if logged_in?
          @has_abuse = Abuse.exists?(["abuseable_type = 'Song' AND abuseable_id = ? AND user_id = ?", @song.id, current_user.id])
        end
      end

      format.xml do
        @tracks = true
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
  # Tries to delete the given Song instance.
  #
  def destroy
    @song = current_user.songs.find(params[:id])
    @song.delete

    flash[:notice] = "Song '#{@song.title}' has been deleted."

    head :ok

  rescue ActiveRecord::RecordNotFound # find
    head :forbidden
  rescue ActiveRecord::ReadOnlyRecord # delete
    head :bad_request
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

    @song = Song.find(params[:id], :include => [:user, {:mixes => {:track => :instrument}}])        
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
    current_user.tag(@song, :with => params.delete(:tag_list)) if params[:tag_list]
    @song.update_attributes!(params[:song])
    @song.reload

    if params[:song].size == 1 && @song.respond_to?(params[:song].keys.first)
      render :text => @song.send(params[:song].keys.first)
    else
      head :ok
    end

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
    tracks = params.delete(:tracks)
    head :bad_request and return if tracks.blank?

    Song.transaction do 
      @song.mixes.clear
    
      tracks.each do |i, track|
        next if track['filename'].blank? || !Track.exists?(['id = ?', track['id']])
        @song.mixes.create! :track_id => track['id'], :volume => track['volume']
      end

      @song.preserve!
    end

    # XXX mostly useless
    respond_to do |format|
      format.xml { render :partial => 'shared/song', :object => @song }
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found

  rescue ActiveRecord::ActiveRecordError
    # XXX this should be handled via JavaScript
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

  def writable_song_required
    @song = Song.find(params[:id])
    head :forbidden and return unless @song.editable_by? current_user
  end
end
