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
    end    
  end
  
  def show
    @genre = Genre.find(params[:id])
    @most_listened_songs = @genre.find_most_listened :limit => 3, :include => :user
    @prolific_users = @genre.find_most_prolific_users :limit => 3
    @songs = Song.find_paginated_by_genre(1, @genre.id)
    
    respond_to do |format|
      format.html
    end
  end
  
end

