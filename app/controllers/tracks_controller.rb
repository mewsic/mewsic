# Myousica Tracks controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller handles operation on Track objects. Login is required to access "write" methods:
# +create+, +rate+, +confirm_destroy+ and +destroy+. The +index+ and +show+ ones are
# public instead.
#
class TracksController < ApplicationController

  before_filter :login_required, :only => [:create, :update, :rate, :destroy, :confirm_destroy]
  before_filter :find_author, :only => :index
  before_filter :accessible_track_required, :only => [:show, :download]
  before_filter :writable_track_required, :only => :update
  before_filter :destroyable_track_required, :only => [:destroy, :confirm_destroy]
  before_filter :redirect_to_root_unless_xhr, :only => [:rate, :destroy, :confirm_destroy]

  protect_from_forgery :except => :create ## XXX FIXME FIX THE MULTITRACK

  # ==== GET /tracks
  # ==== XHR GET /users/:user_id/tracks
  # ==== XHR GET /mbands/:mband_id/tracks
  #
  # Show site-wide tracks index or paginate the tracks indexes in the User/Mband page.
  # FIXME: Only published tracks are shown.
  #
  def index
    if @author
      show_user_or_mband_tracks_index
    else
      show_tracks_index
    end
  end

  protected
    def show_user_or_mband_tracks_index
      @tracks = @author.tracks.public.paginate(:page => params[:page], :per_page => 10)
      render :partial => 'shared/instrument_block', :collection => @tracks
    end

    def show_tracks_index
      @newest_tracks = Track.newest.public.find :all, :limit => 6
      @popular_tags = Tag.find_top :limit => 10, :conditions => {:taggable_type => 'track'}
      @categories = InstrumentCategory.by_name
      @instruments = Instrument.by_name
    end

  public
  # ==== GET /tracks/:id.html
  # ==== GET /tracks/:id.xml
  # ==== GET /tracks/:id.png
  #
  # * HTML format: shows the track page
  # * XML format: shows the XML representation of the given track.
  # * PNG format: streams the waveform png to the client using +x_accel_redirect+.
  #
  def show
    respond_to do |format|
      format.html do
        @has_abuse = @track.abuses.exist?(['user_id = ?', current_user.id]) if logged_in?
      end

      format.xml { render :partial => 'multitrack/track' }

      format.png do
        head :not_found and return if @track.filename.blank?
        x_accel_redirect @track.public_filename(:waveform), :content_type => 'image/png'
      end

    end
  end

  # ==== POST /tracks.xml
  #
  # Creates a new track, whose attributes are carried in the <tt>:track</tt> params hash.
  # If it is Track#valid?, the action renders the XML representation of the newly created
  # Track. if not, the <tt>multitrack/_errors.xml.erb</tt> partial is rendered with a 400
  # status.
  #
  def create
    tags = params.delete(:tag_list) # XXX TEST THIS FSCKING STUFF
    @track = current_user.tracks.create params[:track]
    current_user.tag(@track, :with => tags, :on => :tags) if tags

    respond_to do |format|
      format.xml do
        if @track.valid?
          render :partial => 'multitrack/track', :object => @track, :status => :ok
        else
          render :partial => 'multitrack/errors', :object => @track.errors, :status => :bad_request
        end
      end
    end
  end

  # ==== PUT /tracks/:id
  #
  # Updates the Track with values passed via params[:track].
  # An user can modify only its own tracks.
  # If updating a single attribute, this action renders its new value.
  # If updating multiple ones, nothing is rendered with a 200 status.
  #
  def update
    current_user.tag(@track, :with => params.delete(:tag_list)) if params[:tag_list]
    @track.update_attributes!(params[:track])
    @track.reload

    if params[:track].size == 1 && @track.respond_to?(params[:track].keys.first)
      render :text => @track.send(params[:track].keys.first)
    else
      head :ok
    end

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end
  
  # ==== DELETE /tracks/:id
  #
  # Tries to Track#delete the given track id. Nothing is rendered.
  # If successful => 200, if not => 403, if not found => 404, any other error => 400.
  #
  def destroy
    @track.delete

    flash[:notice] = "Track '#{@track.title}' has been deleted."
    head :ok

  rescue ActiveRecord::ActiveRecordError
    head :forbidden
  end

  # ==== XHR GET /tracks/:id/confirm_destroy
  #
  # Renders the <tt>_destroy.html.erb</tt> partial that asks the user confirmation
  # before deleting a Track. If the Track#deletable? method returns false, means
  # that the track is used by a number of songs: the user is shown a listing and
  # asked to delete its own songs that use the track first or contact support for
  # removal.
  #
  def confirm_destroy
    @songs = @track.dependent_songs unless @track.deletable?
    render :partial => 'destroy'
  end

  # ==== PUT /tracks/:id/rate
  #
  # Rates a track, if Track#rateable_by? returns true, and prints the number of votes if successful.
  # If the Track isn't rateable by the current_user, nothing is rendered with a 400 status.
  #
  def rate
    @track = Track.find(params[:id])
    if @track.rateable_by?(current_user)
      @track.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@track.rating_count} votes"
    else
      render :nothing => true, :status => :forbidden
    end
  end

  # ==== GET /tracks/:id/download
  #
  # Streams the Track mp3 to the client, using +x_accel_redirect+ and by providing a nice title
  # using track attributes: <tt>instrument.description</tt>, <tt>track.title</tt> and
  # <tt>track.user.login</tt>.
  #
  def download
    if @track.filename.blank?
      flash[:error] = 'File not found'
      redirect_to track_path(@track) and return
    end

    # Requires the following nginx configuration:
    #  location /audio {
    #    root /data/mewsic/shared/audio;
    #    internal;
    #  }
    # Or equivalent Apache X-Sendfile config.
    #
    x_accel_redirect @track.public_filename,
      :disposition =>  %[attachment; filename="#{@track.instrument.description} for #{@track.title} by #{@track.user.login}.mp3"],
      :content_type => 'audio/mpeg'
  end

  private
    def find_author
      @author = 
        if params[:user_id]
          User.find_from_param(params[:user_id])
        elsif params[:mband_id]
          Mband.find_from_param(params[:mband_id])
        end
    end

    def accessible_track_required
      @track = Track.find(params[:id], :include => :instrument)
      head :forbidden unless @track.accessible_by? current_user

    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
    
    def writable_track_required
      @track = Track.find(params[:id])
      head :forbidden unless @track.editable_by? current_user

    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def destroyable_track_required
      @track = current_user.tracks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :forbidden
    end

end
