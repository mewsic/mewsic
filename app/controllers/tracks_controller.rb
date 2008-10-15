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
  protect_from_forgery :except => [:create] ## XXX FIXME

  # <tt>XHR GET /users/:user_id/tracks<tt>
  # <tt>XHR GET /mbands/:mband_id/tracks</tt>
  #
  # This action is used to paginate the tracks index in the User/Mband page.
  # If the current user is browsing its own page, a complete listing of tracks
  # is paginated. If it is navigating another user's page, only ideas are
  # displayed. Track#find_paginated_by_user and Track#find_paginated_ideas_by_user
  #
  def index
    if params.include?(:user_id)
      @user = User.find_from_param(params[:user_id])
      @tracks =
        if current_user == @user
          Track.find_paginated_by_user(params[:page], @user)
        else
          Track.find_paginated_ideas_by_user(params[:page], @user)
        end
      render :partial => 'users/tracks'

    elsif params.include?(:mband_id)
      @mband = Mband.find_from_param(params[:mband_id])
      @tracks =
        if @mband.members.include? current_user
          Track.find_paginated_by_mband(params[:page], @mband)
        else
          Track.find_paginated_ideas_by_mband(params[:page], @mband)
        end
      render :partial => 'mbands/tracks'

    end
  end

  # <tt>GET /tracks/:id.xml</tt>
  # <tt>GET /tracks/:id.png</tt>
  #
  # * XML format: shows the XML representation of the given track. Siblings (versions) info is included
  #   if the <tt>siblings</tt> param is present.
  # * PNG format: streams the waveform png to the client using +x_accel_redirect+.
  #
  def show
    @track = Track.find(params[:id], :include => [:instrument, :parent_song] )
    @show_siblings = params.include?(:siblings)
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

  # <tt>POST /tracks.xml</tt>
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

  # <tt>DELETE /tracks/:id</tt>
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

  # <tt>XHR GET /tracks/:id/confirm_destroy</tt>
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

  # <tt>PUT /tracks/:id/rate</tt>
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

  # <tt>XHR PUT /tracks/:id/toggle_idea</tt>
  #
  # Toggles the <tt>idea</tt> flag of a Track. Only the track owner can access this action.
  #
  def toggle_idea
    @track = current_user.tracks.find(params[:id])
    @track.idea = @track.idea? ? false : true
    @track.save

    respond_to do |format|
      format.html { redirect_to user_url(current_user) }
      format.js
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to login_path
  end

  # <tt>GET /tracks/:id/download</tt>
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
    #    root /data/myousica/shared/audio;
    #    internal;
    #  }
    x_accel_redirect @track.public_filename,
      :disposition =>  %[attachment; filename="#{@track.instrument.description} for #{@track.title} by #{@track.user.login}.mp3"],
      :content_type => 'audio/mpeg'

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Track not found'
    redirect_to music_path
  end

end
