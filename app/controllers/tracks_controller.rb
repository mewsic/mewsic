class TracksController < ApplicationController
  
  protect_from_forgery :except => [:create]
  
  def index
    if params.include?(:user_id) 
      @user = User.find(params[:user_id])
      @tracks = Track.find_paginated_by_user(params[:page], @user)
    elsif params.include?(:mband_id)
      @mband = Mband.find(params[:mband_id])
      @tracks = Track.find_paginated_by_mband(params[:page], @mband)
    end
      
    render :layout => false
  end
  
  def show
    @track = Track.find(params[:id], :include => [:instrument, :parent_song] )
    @show_siblings = params.include?(:siblings)
    respond_to do |format|
      format.xml
    end  
  end
  
  def create    
    # HACK because the SWF sends wrong parameters
    attributes = params[:track] || params.reject { |k,v| [:action,:controller].include? k }
    @track = Track.create(attributes)
    
    respond_to do |format|
      format.xml do
        render :xml => @track
      end 
    end
  end  
  
  def rate    
    @track = Track.find(params[:id])
    @track.rate(params[:rate].to_i, current_user)
    render :layout => false, :text => "#{@track.rating_count} votes"
  end
  
  def download
    @track = Track.find(params[:id])
    if @track.filename.blank?
      flash[:error] = 'File not found'
      redirect_to music_path
    end

    # Requires the following nginx configuration:
    #  location /audio {
    #    root /data/myousica/shared/audio;
    #    internal;
    #  }
    response.headers['Content-Disposition'] = %[attachment; filename="#{@track.description}"]
    response.headers['Content-Type'] = 'audio/mpeg'
    response.headers['Cache-Control'] = 'private'
    response.headers['X-Accel-Redirect'] = @track.filename
    render :nothing => true

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Track not found'
    redirect_to music_path
  end
  
end
