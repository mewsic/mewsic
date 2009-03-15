# Myousica Tracks controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller handles operation on Track objects. Login is required to access "write" methods:
# +create+, +rate+, +toggle_idea+, +confirm_destroy+ and +destroy+. The +index+ and +show+ ones are
# public instead.
#
class TracksController < ApplicationController

  before_filter :login_required, :only => [:create, :rate, :toggle_idea, :destroy, :confirm_destroy]
  before_filter :redirect_to_root_unless_xhr, :only => [:index, :confirm_destroy, :rate]
  protect_from_forgery :except => :create ## XXX FIXME

  # ==== XHR GET /users/:user_id/tracks
  # ==== XHR GET /mbands/:mband_id/tracks
  #
  # This action is used to paginate the tracks index in the User/Mband page.
  # Only published tracks are shown.
  #
  def index
    if params.include?(:user_id)
      @author = User.find_from_param(params[:user_id])
      @tracks = @author.tracks.published.paginate(:page => params[:page], :per_page => 7)
    elsif params.include?(:mband_id)
      @author = Mband.find_from_param(params[:mband_id])
      @tracks = @author.tracks.paginate(:page => params[:page], :per_page => 10)
    end

    render :partial => @author.class.table_name + '/tracks'
  end

  # ==== GET /tracks/:id.xml
  # ==== GET /tracks/:id.png
  #
  # * XML format: shows the XML representation of the given track.
  # * PNG format: streams the waveform png to the client using +x_accel_redirect+.
  #
  def show
    @track = Track.find(params[:id], :include => :instrument)

    respond_to do |format|
      format.xml
      format.html { redirect_to '/' }
      format.png do
        if @track.filename.blank?
          flash[:error] = 'file not found'
          redirect_to '/' and return
        end

        x_accel_redirect @track.public_filename(:waveform), :content_type => 'image/png'
      end
    end
  end

  # ==== POST /tracks.xml
  #
  # Creates a new track, whose attributes are carried in the <tt>:track</tt> params hash.
  # If it is Track#valid?, the action renders the XML representation of the newly created
  # Track. if not, the <tt>shared/_errors.xml.erb</tt> partial is rendered with a 400
  # status.
  #
  def create
    @track = current_user.tracks.create params[:track]

    respond_to do |format|
      format.xml do
        if @track.valid?
          render :partial => 'shared/track', :object => @track, :status => :ok
        else
          render :partial => 'shared/errors', :object => @track.errors, :status => :bad_request
        end
      end
    end
  end

  # ==== DELETE /tracks/:id
  #
  # Tries to destroy the given track, if the Track#destroyable? method returns true. Nothing is
  # rendered. if successful => 200, if not => 403, if not found => 404, any other error => 400.
  #
  def destroy
    @track = current_user.tracks.find(params[:id])

    if @track.destroyable?
      @track.songs.destroy_all
      @track.destroy
      flash[:notice] = "Track '#{@track.title}' has been deleted."
      head :ok
    else
      head :forbidden
    end

  rescue ActiveRecord::RecordNotFound # find
    head :not_found
  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  # ==== XHR GET /tracks/:id/confirm_destroy
  #
  # Renders the <tt>_destroy.html.erb</tt> partial that asks the user confirmation
  # before deleting a Track. If the Track#destroyable? method returns false, means
  # that the track is used by a number of songs: the user is shown a listing and
  # asked to delete its own songs that use the track first or contact support for removal.
  #
  def confirm_destroy
    @track = current_user.tracks.find(params[:id])
    @songs = @track.published_songs unless @track.destroyable?
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
      render :nothing => true, :status => :bad_request
    end
  end

  # ==== GET /tracks/:id/download
  #
  # Streams the Track mp3 to the client, using +x_accel_redirect+ and by providing a nice title using
  # the track attributes: <tt>instrument.description</tt>, <tt>track.title</tt> and <tt>track.user.login</tt>.
  #
  def download
    @track = Track.find(params[:id])
    if @track.filename.blank?
      flash[:error] = 'File not found'
      redirect_to :back and return
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

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Track not found'
    redirect_to music_path
  end

end
