class MultitrackController < ApplicationController  
  
  before_filter :login_required
  before_filter :find_user_and_song, :only => :index
  before_filter :check_user_identity, :only => :index
  
  
  def index    
    @song = @user.songs.create(:published => false)
    @genres = Genre.find(:all)
  end
  
  def edit
    render :action => 'index'
  end

  def beta
    index
  end

private

  def find_user_and_song
    if params.include?(:user_id)
      @user = User.find_from_param(params[:user_id])
    elsif params.include?(:song_id)
      @user = current_user
      @song = current_user.songs.find(params[:song_id])      
    end
  end
  
  def check_user_identity
    redirect_to '/' unless @user.id == current_user.id
  end
  
end
