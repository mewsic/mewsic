# Myousica Multitrack Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller implements the myousica M-lab logic: it initializes the multitrack with
# a new song (+index+) or an existing one (+edit+), generates its +config+ and +refresh+es
# the top pane when a new song/track is added to the multitrack editor stage.
#
# It implements also two methods used by the multitrack server app, +authorize+ and +update_song+.
#
class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => :edit

  protect_from_forgery :except => [:authorize, :update_song] # Called only locally

  # ==== GET /multitrack
  #
  # This action renders the multitrack on a blank new empty unpublished song. If the user is
  # logged in, a multitrack auth token is created by the User#enter_multitrack! method and the
  # song is saved into the database.
  #
  # If not, a notice is shown and the song is volatile
  #
  def index    
    if logged_in?
      current_user.enter_multitrack!
      @song = current_user.songs.create_temporary!
    else
      flash.now[:notice] = %(You are not logged in. Saving will be disabled, please <a href="/login">log in</a> or <a href="/signup">sign up</a> if you want to save your work!)
      store_location
      @song = Song.new
    end
  end

  # ==== GET /multitrack/:id
  #
  # This action renders the multitrack in edit mode on the song whose id is passed in the
  # :id parameter. Users can edit their own songs, if they aren't published yet, and can
  # only remix (fork) existing published ones.
  #
  def edit
    @song = Song.find(params[:id])
    if @song.private? && @song.editable_by?(current_user)
      @edit = true # XXX remove me, if possible
      render :action => 'index'
    elsif @song.public?
      @remix = @song.create_remix
      redirect_to multitrack_edit_path(@remix)
    else
      redirect_to '/'
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Song not found..'
    redirect_to '/'
  end

  # ==== GET /multitrack.xml
  #
  # This action renders the multitrack configuration.
  #
  def config
    respond_to { |format| format.xml }
  end

  # ==== GET /multitrack/refresh/:id
  #
  # This action is called by the multitrack SWF when a new track is added to the stage,
  # in order to update tracks number and song runtime in the top pane.
  #
  #def refresh
  #  song = Song.find(params[:id])

  #  render :update do |page|
  #    page['mlab_tracks'].update song.tracks.count
  #    page['mlab_runtime'].update song.length
  #  end
  #end

  # ==== POST /multitrack/_/:user_id
  #
  # When an user enters the multitrack, a random token is generated and saved into
  # the DB, this token is then checked by the multitrack-server app, in order to
  # authorize or reject requests.
  #
  # The multitrack-server app is stateless, so the only way for it to check whether
  # an upload or an encode request should be fulfilled is to ask this app.
  #
  # This action URI should never be made public.
  #
  def authorize
    @user = User.find_by_id_and_multitrack_token(params[:user_id], params[:token])
    head(@user ? :ok : :forbidden)
  end

  # ==== POST /multitrack/s/:user_id
  #
  # This action is called by the multitrack-server app when the final mixdown of a
  # song is completed, in order to not make the user wait for it, after hitting "save
  # & close" in the editor.
  #
  # This action URI should never be made public.
  #
  def update_song
    unless params[:user_id] && params[:filename] && params[:length]
      head :bad_request and return
    end
    user = User.find(params[:user_id]) 
    song = user.songs.private.find(params[:song_id]) # XXX FIXME .private is wrong
    song.filename = params[:filename]
    song.seconds = params[:length]
    song.save!

    head :ok

  rescue ActiveRecord::RecordNotFound
    head :not_found

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

end
