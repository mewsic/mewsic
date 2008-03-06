class TracksController < ApplicationController
  
  def index
    @tracks = Track.find_paginated_by_user(params[:page], params[:id])
    render :layout => false
  end
  
  def show
    @track = Track.find(params[:id])
    @show_siblings = params.include?(:siblings)
    respond_to do |format|
      format.xml
    end
  end
  
end
