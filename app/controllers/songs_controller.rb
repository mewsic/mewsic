class SongsController < ApplicationController
  def index
    if params.has_key?("genre_id")
      @songs = Song.find_paginated_by_genre(params[:page], params[:genre_id])
      params[:id] = params[:genre_id]
    end
    if params.has_key?("user_id")
      @songs = Song.find_paginated_by_user(params[:page], params[:user_id])
      params[:id] = params[:user_id]
    end
    render :layout => false
  end
end
