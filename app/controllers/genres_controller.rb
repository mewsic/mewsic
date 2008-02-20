class GenresController < ApplicationController
  def index      
    @genres = Genre.find_paginated(params[:page])
    render :layout => false
  end
  
  def show
    @genre = Genre.find(params[:id])
    @most_listened_songs = @genre.find_most_listened :limit => 3, :include => :user
    @prolific_users = @genre.find_most_prolific_users :limit => 3
    @songs = Song.find_paginated_by_genre(1, @genre.id)
  end
  
end

