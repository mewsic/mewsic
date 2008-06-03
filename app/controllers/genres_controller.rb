class GenresController < ApplicationController  
    
  def index              
    respond_to do |format|
      format.html do
        @genres = Genre.find_paginated(params[:page])
        render :layout => false
      end
      format.xml do
        @genres = Genre.find(:all, params[:page])
      end
      format.js do
        @genres = Genre.find(:all).collect{|g| params.include?(:ids) ? g.id : g.name}
        headers["Content-Type"] = "application/json;"
        render :text => @genres.to_json
      end
    end    
  end
  
  def show
    @genre = Genre.find_from_param(params[:id])
    @most_listened_songs = @genre.find_most_listened :limit => 3, :include => :user
    @prolific_users = @genre.find_most_prolific_users :limit => 3
    @songs = Song.find_paginated_by_genre(1, @genre)
    
    respond_to do |format|
      format.html
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Genre not found..'
    redirect_to '/'
  end

protected

  def to_breadcrumb_link
    ['Genres', music_path]
  end
  
end

