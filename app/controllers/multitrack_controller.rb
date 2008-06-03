class MultitrackController < ApplicationController  
  
  before_filter :login_required
  before_filter :find_user
  before_filter :check_user_identity
  
  
  def index    
    @song = @user.songs.create(:published => false)
    @genres = Genre.find(:all)
  end

private

  def find_user
    @user = User.find_from_param(params[:user_id])
  end
  
  def check_user_identity
    redirect_to '/' unless @user.id == current_user.id
  end
  
end
