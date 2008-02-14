class TracksController < ApplicationController
  def index
    @tracks = Track.find_paginated_by_user(params[:page], params[:id])
    render :layout => false
  end
end
