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
  before_filter :accessible_song_required, :only => [:show, :tracks, :download]
  before_filter :writable_song_required, :only => [:update, :mix]
  before_filter :destroyable_song_required, :only => [:destroy, :confirm_destroy]
  before_filter :redirect_to_root_unless_xhr, :only => [:tracks, :rate, :confirm_destroy]

  protect_from_forgery
  
  # ==== XHR GET /songs?[user_id|mband_id]=ID
  #
  # * HTML format: renders a paginated index of songs by User or Mband. Every
  #   model has its own template: <tt>{users,mbands}/_songs.html.erb</tt>.
  #
  # # FIXME # Only public songs are returned.
  #
  def index
    if [:user_id, :mband_id].any? { |k| params.has_key? k }
      show_user_or_mband_songs
    else
      show_songs_index
    end
  end

  protected
  def show_user_or_mband_songs_index
    @author =
      if params[:user_id]
        User.find_from_param(params[:user_id])
      elsif params[:mband_id]
        Mband.find_from_param(params[:mband_id])
      end
   
    @songs = @author.songs.public.paginate(:page => params[:page], :per_page => 3)
    render :layout => false

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def show_songs_index
    @newest_songs = Song.find_newest :limit => 5
    @coolest_songs = Song.find_best :limit => 5
  end
  
  public
  # ==== GET /songs/:song_id
  # ==== GET /songs/:song_id.xml
  # ==== GET /songs/:song_id.png
  #
  # * HTML format: shows the song page
  # * XML format: shows the XML representation of the given song.
  # * PNG format: streams the waveform png to the client using +x_accel_redirect+.
  #
  def show
    respond_to do |format|

      format.html do
        @has_abuse = @song.abuses.exists?(['user_id = ?', current_user.id]) if logged_in?
      end

      format.xml do
        @tracks = true # show the tracks in the XML repr
        render :partial => 'multitrack/song'
      end

      format.png do
        head :not_found and return if @song.filename.blank?
        x_accel_redirect @song.public_filename(:waveform), :content_type => 'image/png'
      end
    end
  end

  # ==== DELETE /songs/:id
  #
  # Tries to delete the given Song instance. Only the creator can delete it.
  #
  # TODO: What about Mband-owned songs?
  #
  def destroy
    @song.delete

    flash[:notice] = "Song '#{@song.title}' has been deleted."
    head :ok
  end

  # ==== XHR GET /songs/:id/confirm_destroy
  #
  # Renders the <tt>_destroy.html.erb</tt> partial that asks the user confirmation
  # before deleting a Song. Only the creator can delete it.
  #
  # TODO: What about Mband-owned songs?
  #
  def confirm_destroy
    render :partial => 'destroy'
  end
  
  # ==== XHR GET /songs/:id/tracks
  #
  # Renders the <tt>_track.html.erb</tt> partial for every track in the given song.
  #
  def tracks
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
  # <tt>multitrack/_errors.xml.erb</tt> partial is rendered instead.
  #
  # XXX THIS HAS TO BE REWORKED OUT WITH ADD/REMOVE TRACK METHODS TO BETTER SPECIFY PERMISSIONS
  #
  def mix
    tracks = params.delete(:tracks)
    head :bad_request and return if tracks.blank?

    Song.transaction do 
      @song.mixes.clear
    
      tracks.each do |i, track|
        next unless Track.exists?(['id = ?', track['id']]) # XXX REMOVE ME, SHOULD BE FIXED IN AS3
        @song.mixes.create :track_id => track['id'], :volume => track['volume']
      end

      @song.preserve!
    end

    # XXX mostly useless
    respond_to do |format|
      format.xml { render :partial => 'multitrack/song', :object => @song }
    end

  rescue NoMethodError, TypeError
    head :bad_request

  rescue ActiveRecord::ActiveRecordError
    # XXX this should be handled via JavaScript
    respond_to do |format|
      format.xml do
        render :partial => 'multitrack/errors', :object => @song.errors, :status => :bad_request
      end
    end
  end    
  
  # ==== PUT /songs/:id/rate
  #
  # Rates a song, if Song#rateable_by? returns true, and prints the number of votes if successful.
  # If the Song isn't rateable by the current_user, nothing is rendered with a 403 status.
  #
  def rate    
    @song = Song.find(params[:id])
    if @song.rateable_by?(current_user)
      @song.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@song.rating_count} votes"
    else
      render :nothing => true, :status => :forbidden
    end
  end       

  # ==== GET /songs/:id/download
  #
  # Streams the Song mp3 to the client, using +x_accel_redirect+ and by providing a nice title using
  # the song attributes: <tt>song.title</tt> and <tt>song.user.login</tt>.
  #
  def download
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
  end
  
protected

  # Renders "Music" into the breadcrumb with a link to <tt>music_path</tt> (<tt>/music</tt>)
  #
  def to_breadcrumb_link
    ['Music', music_path]
  end

  def accessible_song_required
    @song = Song.find(params[:id], :include => [:user, {:mixes => {:track => :instrument}}])        
    head :forbidden unless @song.accessible_by? current_user

    # XXX REMOVE ME # CURRENTLY SONG ID = 0 MEANS "NOT LOGGED IN"
  rescue ActiveRecord::RecordNotFound
    if params[:id].to_i.zero?
      head :ok
    else
      raise
    end
  end

  def writable_song_required
    @song = Song.find(params[:id])
    head :forbidden unless @song.editable_by? current_user

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def destroyable_song_required
    @song = current_user.songs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :forbidden
  end
end
