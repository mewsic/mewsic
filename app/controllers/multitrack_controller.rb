class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => :edit

  def index    
    if logged_in?
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

end
