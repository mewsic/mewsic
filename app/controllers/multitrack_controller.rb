class MultitrackController < ApplicationController  
  
  before_filter :login_required, :only => :edit

  def index    
    @song = Song.new :published => false
    if logged_in?
      @song.user = current_user
      @song.save!
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
