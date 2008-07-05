class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => :edit

  def index    
    @song = Song.new :published => false
    if logged_in?
      @song.user = current_user
      @song.save!
    else
      flash.now[:notice] = %(You are not logged in. Saving will be disabled, please <a href="/login">log in</a> or <a href="/signup">sign up</a> if you want to save your work!)
    end
  end

  def edit
    @song = Song.find params[:song_id]
    unless @song.user.id == current_user.id
      raise ActiveRecord::RecordNotFound
    end

    render :action => 'index'

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Song not found..'
    redirect_to '/' and return
  end
  
  def config
    respond_to { |format| format.xml }
  end

end
