class TracksController < ApplicationController
  
  before_filter :login_required, :only => [:create, :rate, :toggle_idea]
  before_filter :check_track_owner, :only => [:toggle_idea]
  protect_from_forgery :except => [:create] ## XXX FIXME
  
  def index
    redirect_to '/' and return unless request.xhr?

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

        response.headers['Content-Disposition'] = 'inline'
        response.headers['Content-Type'] = 'image/png'
        response.headers['Cache-Control'] = 'private'
        response.headers['X-Accel-Redirect'] = @track.public_filename :waveform

        render :nothing => true
      end
    end  
  end

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
  
  def rate    
    @track = Track.find(params[:id])
    if @track.rateable_by?(current_user)
      @track.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@track.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end
  
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
    response.headers['Content-Disposition'] = %[attachment; filename="#{@track.instrument.description} for #{@track.title} by #{@track.user.login}.mp3"]
    response.headers['Content-Type'] = 'audio/mpeg'
    response.headers['Cache-Control'] = 'private'
    response.headers['X-Accel-Redirect'] = @track.public_filename
    render :nothing => true

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Track not found'
    redirect_to music_path
  end    
  
  def toggle_idea
    @track.idea = @track.idea? ? false : true
    @track.save
    
    respond_to do |format|
      format.html { redirect_to user_url(current_user) }
      format.js
    end        
  end

private
  
  def check_track_owner
    @user = User.find_from_param(params[:user_id])            
    @track = Track.find(params[:id])
    if @user != current_user || @track.user != current_user
      redirect_to new_session_path
    end
  end
  
end
