class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => [:edit, :beta_edit]
  before_filter :stable_multitrack, :only => [:index, :edit]
  before_filter :beta_multitrack, :only => [:beta_index, :beta_edit]

  protect_from_forgery :except => [:authorize, :update_song] # Called only locally

  def index    
    if logged_in?
      current_user.enter_multitrack!
      @song = current_user.songs.create_unpublished!
    else
      not_logged_in_notice
      store_location
      @song = Song.new :published => false
      @song.randomize!
    end
  end

  def beta_index
    index
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

  def beta_edit
    edit
  end
  
  def config
    respond_to { |format| format.xml }
  end

  def refresh
    song = Song.find(params[:id])

    render :update do |page|
      page['mlab_tracks'].update song.tracks.count
      page['mlab_runtime'].update song.length
    end
  end

  # Used by multitrack server
  def authorize
    @user = User.find_by_id_and_multitrack_token(params[:user_id], params[:token])
    head(@user ? :ok : :forbidden)
  end

  def update_song
    unless params[:user_id] && params[:filename] && params[:length]
      head :bad_request and return
    end
    user = User.find(params[:user_id])
    song = user.songs.find(params[:song_id])
    song.filename = params[:filename]
    song.seconds = params[:length]
    song.publish!

    head :ok

  rescue ActiveRecord::RecordNotFound
    head :not_found

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  private
    def stable_multitrack
      @swf = 'Adelao_Myousica_Multitrack_Editor.swf'
    end

    def beta_multitrack
      @swf = 'Adelao_Myousica_Multitrack_Editor_beta.swf'
    end

end
