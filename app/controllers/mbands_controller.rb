# Myousica M-Band Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This RESTful controller implements operations on M-Bands, groups of myousicians that play
# together online. M-Bands have got a page (+show+), can be created when inviting an user to
# a new M-band (+create+), +update+d and +destroy+ed. XXX FIXME: only the leader should be
# able to destroy an m-band.
#
# Login is required except for the +show+ action, 
#
class MbandsController < ApplicationController
  
  before_filter :login_required,  :except => [:index, :show]
  before_filter :find_mband, :except => [:index, :new, :create]
  before_filter :mband_membership_required,  :only => [:update, :destroy, :set_leader]

  protect_from_forgery :except => :update # XXX FIXME

  # ==== GET /mbands
  #
  def index
    @mbands = Mband.real.paginate(:per_page => 10, :page => params[:page])
  end

  # ==== GET /mbands/:id
  #
  # Shows the M-Band page, displaying the whole track list if the user is a member of the
  # M-band, or only tracks marked as ideas if not.
  #
  def show
    current_user_mband_page = @mband.band_membership_with(current_user)

    @songs = @mband.songs.public.paginate(:page => 1, :per_page => 7)
    @songs_count = @mband.songs.public.count

    @tracks = @mband.tracks.public.paginate(:page => 1, :per_page => 7)
    @tracks_count = @mband.tracks.public.size
  end

  # ==== POST /mbands
  #
  # Creates a new M-Band, setting the current_user as the leader, and creates a new 
  # MbandMembership between the current user and the newly created M-Band, accepted
  # at Time.now.
  #
  def create
    @mband = Mband.new(params[:mband])
    @mband.leader = current_user
    respond_to do |format|
      if @mband.save
        membership = MbandMembership.create(:mband => @mband, :user => current_user)
        membership.update_attribute(:accepted_at, Time.now)
        flash[:notice] = 'M-band created successfully'
        format.html { redirect_to(@mband) }
        #format.xml  { render :xml => @mband, :status => :created, :location => @mband }
      else
        flash[:notice] = 'Cannot create your M-Band'
        format.html { redirect_to user_url(current_user) }
        #format.xml  { render :xml => @mband.errors, :status => :unprocessable_entity }
      end
    end
  end

  # ==== PUT /mbands/:id
  #
  # Updates the attributes of and M-Band. This code uses a trick to identify if the request
  # was made by the Ajax.Inplaceeditor prototype widget: if there are less than 3 attributes
  # set in the parameters array, the changed value of the first one is printed out as text..
  # in order for the in place editor to display it to the user.
  #
  # If the update fails, validation errors are printed out separated by newlines with a 400
  # status, but only if the request comes through XHR.
  #
  def update
    if @mband.update_attributes(params[:mband])
      @mband.reload
      if params[:mband] && params[:mband].keys.size <= 2
        render(:text => @mband.send(params[:mband].keys.first)) and return
      end
      render :nothing => true
    else
      render :text => @mband.errors.map(&:last).join("\n"), :status => 400 if request.xhr?
    end  
  end

  # ==== DELETE /mbands/:id
  #
  # Destroys an M-Band. Currently there is no link on the site that calls this method,
  # and FIXME it should be fixed to make some sanity checks.
  #
  def destroy
    @mband.destroy

    respond_to do |format|
      format.html { redirect_to(mbands_url) }
      format.xml  { head :ok }
    end
  end
  
  # ==== PUT /mbands/:id/rate
  #
  # Rates an M-Band, by calling ActiveRecord::Acts::Rated::RateMethods::rate method of the
  # <tt>vendor/plugins/medlar_acts_as_rated</tt> plugin, if the Mband is rateable by the
  # current user (see Mband#rateable_by). If true, the number of votes is printed out as
  # text, if false, nothing is printed with a 400 status.
  #
  def rate    
    if @mband.rateable_by?(current_user)
      @mband.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@mband.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end
  
  # ==== PUT /mbands/:id/set_leader
  #
  # Sets a new user as the leader, iff the current user is the leader of the Mband. If not,
  # nothing is rendered with a 400 status.
  #
  def set_leader    
    @user = User.find_from_param(params[:user_id])
    @mband = Mband.find_from_param(params[:id])
    unless current_user.is_leader_of?(@mband)
      render :nothing => true, :status => :bad_request and return
    end
    @mband.leader = @user
    @mband.save
    redirect_to mband_url(@mband)
  end

protected

  # Generates the breadcrumb link: if the +find_mband+ method has been called,
  # an mband is shown so "Mband" is generated. "Mbands" otherwise. The link
  # points to the bands_and_deejays_path.
  #
  def to_breadcrumb_link
    [@mband ? "Mband" : "Mbands", bands_and_deejays_path]
  end

private
  
  # Filter to find an mband from the :id parameter
  # 
  def find_mband
    @mband = Mband.find_from_param(params[:id], :include => :members)

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'M-band not found..'
    redirect_to '/'
  end
  
  # Filter that checks whether the current user is a member of the M-Band.
  #
  def mband_membership_required
    redirect_to '/' unless @mband.members.include?(current_user)
  end

end
