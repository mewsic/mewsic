# Myousica Players Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
# 
# This simple controller handles the rendering of the Myousica Audio Player. Its only
# action is +show+, requested via XHR. The stream to play is found via the +find_playable+
# before filter.
#
class PlayersController < ApplicationController
  
  layout false

  before_filter :redirect_to_root_unless_xhr, :except => :increment
  before_filter :find_playable

  # ==== XHR GET /songs/:song_id/player.html
  # ==== XHR GET /tracks/:track_id/player.html
  #
  # Renders the <tt>app/views/show.html.erb</tt> view, which contains the JavaScript that
  # initializes the player SWF object. Currently the play count is incremented when the 
  # player is loaded, leading to easy abuse. It will be fixed soon.
  #
  def show
    redirect_to '/' and return unless @playable

    session[:playcount_barrier] = Time.now.to_i + @playable.seconds/2
    @playable_type = @playable.class.name.underscore
    @playcount_path = send("#{@playable_type}_increment_path", @playable)
    @waveform = send("formatted_#{@playable_type}_path", @playable, 'png')
  end

  def increment
    if session[:playcount_barrier].nil? || Time.now.to_i < session[:playcount_barrier]
      head :bad_request
    else
      @playable.increment_listened_times
      head :ok
    end
    session[:playcount_barrier] = nil
  end
  
private
  
  # Filter that founds a playable stream using the passed <tt>song_id</tt> or <tt>track_id</tt>
  # parameter. If no playable is found, the user is redirected to '/'.
  #
  def find_playable
    @playable = if params[:track_id]
      Track.find(params[:track_id])
    elsif params[:song_id]
      Song.find(params[:song_id])
    else
      redirect_to '/' and return
    end
  end

end
