class TracksController < ApplicationController
  
  def index
    @tracks = Track.find_paginated_by_user(params[:page], params[:id])
    @user = User.find(params[:id])
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
    @track = Track.create(params[:track])
    
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
  
end
