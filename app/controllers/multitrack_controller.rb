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
  before_filter :updateable_mixable_required, :only => [:update_song, :update_track]
  # before_filter :localhost_required, :only => [:update_song, :update_track]

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
      load_user_stuff
      current_user.enter_multitrack!
      @song = current_user.songs.create_temporary!
    else
      flash.now[:notice] = %(You are not logged in. Save and record will be disabled, please <a href="/login">log in</a> or <a href="/signup">sign up</a> if you want to save your work!)
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
      load_user_stuff
      current_user.enter_multitrack!
      render :action => 'index'
    elsif @song.public?
      @remix = @song.create_remix_by(current_user)
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
  # All the logic is inside the +updateable_mixable_required+ filter. DRY!
  #
  def update_song
    head :ok
  end

  def update_track
    head :ok
  end

  private
    def updateable_mixable_required
      unless params[:user_id] && params[:filename] && params[:length]
        head :bad_request and return
      end

      @user = User.find params[:user_id]
      @mixable =
        if params[:song_id]
          @user.songs.find params[:song_id]
        elsif params[:track_id]
          @user.tracks.find params[:track_id]
        end

      head :bad_request and return unless @mixable

      @mixable.filename = params[:filename]
      @mixable.seconds = params[:length]
      @mixable.save!

    rescue ActiveRecord::RecordNotFound
      head :not_found

    rescue ActiveRecord::ActiveRecordError
      head :forbidden
    end

    def load_user_stuff
      @songs = current_user.songs.stuffable.newest
      @tracks = current_user.tracks.stuffable.newest
    end

end
