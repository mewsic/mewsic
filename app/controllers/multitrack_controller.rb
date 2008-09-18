class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => :edit

  def index    
    @swf = 'Adelao_Myousica_Multitrack_Editor.swf'
    if logged_in?
      current_user.enter_multitrack!
      @song = current_user.songs.create_unpublished!
    else
      flash.now[:notice] = %(You are not logged in. Saving will be disabled, please <a href="/login">log in</a> or <a href="/signup">sign up</a> if you want to save your work!)
      store_location
      @song = Song.new :published => false
      @song.randomize!
    end
  end

  def beta
    index
    @swf = 'Adelao_Myousica_Multitrack_Editor_beta.swf'
    render :action => 'index'
  end

  def edit
    @edit = true
    @song = current_user.published_songs.find(params[:id])
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
      #page['mlab_instruments'].update instruments_used_in(song)
    end
  end

  # Used by multitrack server
  def authorize
    head :ok # XXX FIXME XXX
    #@user = User.find_by_id_and_multitrack_token(params[:user_id], params[:token])
    #head(@user ? :ok : :forbidden)
  end

  def update_song
    unless params[:user_id] && params[:filename] && params[:length]
      head :bad_request and return
    end
    user = User.find(params[:user_id])
    song = user.songs.find(params[:song_id])
    song.filename = params[:filename]
    song.seconds = params[:length]
    song.published = true
    song.save!

    head :ok

  rescue ActiveRecord::RecordNotFound
    head :not_found

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

end
