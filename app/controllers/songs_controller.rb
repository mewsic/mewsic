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
  
  def show
    @song = Song.find(params[:id], :include => [{ :mixes => { :track => [:instrument, :parent_song] } }, :genre])
    @show_siblings  = params.include?(:siblings)
    @show_edit_info = params.include?(:edit) && params[:edit] == 'true'
    respond_to do |format|
      format.xml
    end
  end
  
end
