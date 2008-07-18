class MbandsController < ApplicationController
  
  before_filter :login_required,  :except => [:index, :show]
  before_filter :find_mband, :except => [:index, :new, :create]
  before_filter :mband_membership_required,  :only => [:update, :destroy, :set_leader]

  protect_from_forgery :except => :update   

  helper :users

  # GET /mbands/1
  # GET /mbands/1.xml
  def show
    @songs = Song.find_paginated_by_mband(1, @mband)
    @tracks, @tracks_count =
      if @mband.members.include? current_user 
        [Track.find_paginated_by_mband(1, @mband), @mband.tracks_count]
      else
        [Track.find_paginated_ideas_by_mband(1, @mband), @mband.ideas_count]
      end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @mband }
    end
  end

  # POST /mbands
  # POST /mbands.xml
  def create
    @mband = Mband.new(params[:mband])
    @mband.leader = current_user
    respond_to do |format|
      if @mband.save
        membership = MbandMembership.create(:mband => @mband, :user => current_user)
        membership.update_attribute(:accepted_at, Time.now)
        flash[:notice] = 'M-band created successfully'
        format.html { redirect_to(@mband) }
        format.xml  { render :xml => @mband, :status => :created, :location => @mband }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mband.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mbands/1
  # PUT /mbands/1.xml  
  
  def update
    # FIXME: cambiare l'output a seconda del formato richiesto e se ci sono errori.
    if @mband.update_attributes(params[:mband])
      if params[:mband] && params[:mband].keys.size <= 2
        render(:text => @mband.send(params[:mband].keys.first)) and return
      end
      render :layout => false
    else
      render :text => @mband.errors.map(&:last).join("\n"), :status => 400 if request.xhr?
    end  
  end

  # DELETE /mbands/1
  # DELETE /mbands/1.xml
  def destroy
    @mband.destroy

    respond_to do |format|
      format.html { redirect_to(mbands_url) }
      format.xml  { head :ok }
    end
  end
  
  def rate    
    if @mband.rateable_by?(current_user)
      @mband.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@mband.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end
  
  def set_leader    
    @user = User.find_from_param(params[:user_id])
    @mband = Mband.find_from_param(params[:id])
    redirect_to '/' and return unless current_user.is_leader_of?(@mband).inspect
    @mband.leader = @user
    @mband.save    
    redirect_to mband_url(@mband)
  end

protected

  def to_breadcrumb_link
    [@mband ? "Mband" : "Mbands", bands_and_deejays_path]
  end

private
  
  def find_mband
    @mband = Mband.find_from_param(params[:id], :include => :members)

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'M-band not found..'
    redirect_to '/'
  end
  
  def mband_membership_required
    redirect_to '/' unless @mband.members.include?(current_user)
  end

end
