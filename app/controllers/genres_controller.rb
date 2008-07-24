class GenresController < ApplicationController  
    
  def index              
    respond_to do |format|
      format.html do
        redirect_to(music_path + '#genres') and return unless request.xhr?        
        @genre_char = params.include?(:c) && ('A'..'Z').include?(params[:c]) ? params[:c] : 'Z'
        @genres = Genre.find_with_songs(:all, :conditions => ["name LIKE ?", "#{@genre_char}%"])
        @genre_chars = Genre.find_with_songs(:all).map { |g| g.name.first.upcase }.uniq.sort
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

  def rss
    @genre = Genre.find_from_param(params[:genre_id])
    @songs = @genre.published_songs.find(:all, :limit => 40)

    respond_to do |format|
      format.xml
    end
  end

protected

  def to_breadcrumb_link
    ['Genres', music_path + '#genres']
  end
  
end

