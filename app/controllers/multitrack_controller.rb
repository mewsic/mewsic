class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => :edit
  before_filter :multitrack_token_required, :only => [:authorize, :update_song]

  def index    
    if logged_in?
      current_user.enter_multitrack!
      @song = current_user.songs.create_unpublished!
    else
      flash.now[:notice] = %(You are not logged in. Saving will be disabled, please <a href="/login">log in</a> or <a href="/signup">sign up</a> if you want to save your work!)
      store_location
      @song = Song.create_unpublished!
    end
  end

  def edit
    @song = current_user.songs.find(params[:id], :conditions => ['published = ?', true])
    render :action => 'index'

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Song not found..'
    redirect_to '/'
  end
  
  def config
    respond_to { |format| format.xml }
  end

  def refresh
    song = Song.find(params[:id])

    render :update do |page|
      page['mlab_tracks'].update song.tracks.count
      page['mlab_runtime'].update song.length
      page['mlab_instruments'].update instruments_used_in(song)
    end
  end

  # Used by multitrack server
  def authorize
    head :ok
  end

  def update_song
    unless params[:id] && params[:filename] && params[:length]
      head :bad_request and return
    end

    song = @user.songs.find(params[:song_id])
    song.filename = params[:filename]
    song.seconds = params[:length]
    song.save!

    head :ok

  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  protected
    def multitrack_token_required
      @user = User.find_by_id_and_multitrack_token(params[:id], params[:token])
      head :forbidden unless @user
    end

end
