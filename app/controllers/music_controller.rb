# Myousica Music Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
# 
# This simple controller implements the <tt>/music</tt> page, which has got an +index+
# and 3 refreshable blocks: the +newest+ list and the two +top+ lists.
#
class MusicController < ApplicationController
  before_filter :redirect_unless_xhr, :except => :index

  # ==== GET /music
  #
  # Renders the whole music page, by fetching best songs, most used tracks, genres and
  # newest songs. Nothing special here.
  #
  def index
    @best_songs = Song.find_best :limit => 3, :include => [:tracks, :user]
    @most_used_tracks = Track.find_most_used :limit => 3
    @genre_chars = Genre.find_with_songs(:all).map { |g| g.name.first.upcase }.uniq.sort
    @genres = Genre.find_with_songs(:all, :conditions => ["name LIKE ?", "#{@genre_chars.first}%"])
    @newest = Song.find_newest_paginated :page => 1, :per_page => 5, :include => :user
  end

  # ==== XHR GET /music/newest
  #
  # Renders the <tt>_newest.html.erb</tt> partial to implement the pagination of newest songs.
  #
  def newest
    @newest = Song.find_newest_paginated :page => params[:page], :per_page => 5, :include => :user
    render :partial => 'newest'
  end

  # ==== XHR GET /music/top?type=[song|track]
  #
  # Renders the two top blocks of best songs and most used tracks, discriminating which to show
  # using the type parameter. Results are shown randomized. This code is quite complicated.
  #
  def top
    unless %w(song track).include? params[:type]
      render :nothing => true, :status => :bad_request and return
    end

    model, method, partial, options = {
      'song'  => [Song,  :find_best, 'best_song', {:include => [:tracks, :user]}],
      'track' => [Track, :find_most_used, 'most_used_track', {}]
    }.fetch(params[:type])

    collection = model.send(method, options.merge(:limit => 15)).sort_by{rand}[0..2]
    collection = collection.sort {|b,a| (a.rating_avg || 0) <=> (b.rating_avg || 0)}

    render :partial => partial, :collection => collection
  end

  private
    # Redirects to music_url unless the request comes through XHR.
    #
    def redirect_unless_xhr
      redirect_to music_url unless request.xhr?
    end

end
