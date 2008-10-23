# Myousica Genres Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This RESTful controller implements listing of genres for the <tt>/music</tt> page and for
# XML (multitrack) and JS (forms) requests, showing songs that pertain to a genre and RSS
# feeds of the newest songs.
#
class GenresController < ApplicationController  

  # ==== GET /genres.:format
  #
  # Print out a listing of genres. Depending on the format, different actions are carried out.
  # 
  # HTML: for the <tt>/music</tt> page, print out genres with songs (Genre#find_with_songs) and
  # the last 3 songs of it (Genre#last_songs, called by <tt>app/views/music/_genre.rhtml</tt>).
  # The view for this method is <tt>app/views/music/_genres.rhtml</tt>.
  #
  # XML: Returns an XML sheet of genres. If the <tt>search</tt> parameter is given, only genres
  # with songs are selected, it is used by the advanced search features of the multitrack. The
  # full genre list is used in the upload/record track dialog of the multitrack, instead.
  #
  # JS: Returns a JSON array containing all the genre names. It is used by the M-Lab in place
  # select (see <tt>app/views/multitrack/index.html.erb</tt>, <tt>mlab_genre</tt>). If the <tt>
  # ids</tt> parameter is given, a JSON array of the genre ids is returned.
  #
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
        @genres = params[:search] ? Genre.find_with_songs(:all, :order => 'name') :
          Genre.find(:all, :order => 'name')
      end
      format.js do
        @genres = Genre.find(:all).collect{|g| params.include?(:ids) ? g.id : g.name}
        render :text => @genres.to_json
      end
    end    
  end
  
  # ==== GET /genres/:genre_id
  #
  # Show the genre page, that contains a listing of genre's songs, the most listened ones and
  # most prolific users. Only HTML output is supported. When a genre is not found, user is
  # redirected to /.
  #
  # If a Genre has got no songs, the user is redirected to <tt>music_path</tt>.
  #
  def show
    @genre = Genre.find_from_param(params[:id])
    @most_listened_songs = @genre.find_most_listened :limit => 3, :include => :user
    @prolific_users = @genre.find_most_prolific_users :limit => 3
    @songs = Song.find_paginated_by_genre(1, @genre)
    
    redirect_to music_path and return if @songs.empty?

    respond_to do |format|
      format.html
    end

  rescue ActiveRecord::RecordNotFound
    if googlebot?
      render :nothing => true, :status => :not_found
    else
      # XXX HACK HACK HACK XXX
      if params[:id] =~ /acustic/i
        redirect_to '/genres/Acoustic'
      else
        flash[:error] = 'Genre not found..'
        redirect_to '/'
      end
    end
  end

  # ==== GET /genres/:genre_id/rss.xml
  #
  # Generates an RSS feed of 40 most recent published songs.
  #
  def rss
    @genre = Genre.find_from_param(params[:genre_id])
    @songs = @genre.published_songs.find(:all, :limit => 40)
    @pubdate = @songs.first.created_at rescue Time.now

    respond_to do |format|
      format.xml
    end
  end

protected

  # Helper that generates the breadcrumb link for this controller.
  # The target is /music#genres, because genre index is displayed only on the music page.
  #
  def to_breadcrumb_link
    ['Genres', music_path + '#genres']
  end
  
end

