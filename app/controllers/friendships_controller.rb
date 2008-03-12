class FriendshipsController < ApplicationController
  
  before_filter :login_required
  
  def create
    @friend = User.find(params[:friend_id])
    current_user.request_friendship_with(@friend)
    redirect_to user_path(@friend)  
  end
  
end
