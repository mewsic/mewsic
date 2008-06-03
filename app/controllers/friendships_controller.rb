class FriendshipsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  def create    
    @friend = User.find(params[:friend_id])
    Friendship.create_or_accept(@user, @friend)    
    redirect_to user_path(@friend)  
  end
  
  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy_or_unaccept(@user)
    redirect_to user_path(@friendship.friendshipped_for_me == @user ? @friendship.friendshipped_by_me : @friendship.friendshipped_for_me)
  rescue ActiveRecord::RecordNotFound
    redirect_to user_path(@user)
  end

private

  def find_user
    @user = User.find_from_param(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to '/'  
  end
  
  def check_current_user
    redirect_to '/' unless @user.id == current_user.id
  end    
  
end
