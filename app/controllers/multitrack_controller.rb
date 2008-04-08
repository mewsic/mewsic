class MultitrackController < ApplicationController  
  
  def index
    @user = User.find(params[:user_id])
    @song = @user.songs.create
  end
end
