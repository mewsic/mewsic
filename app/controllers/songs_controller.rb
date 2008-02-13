class SongsController < ApplicationController
  def index
    @songs = Song.find_paginated_by_genre(params[:page], params[:id])
    render :layout => false
  end
end
