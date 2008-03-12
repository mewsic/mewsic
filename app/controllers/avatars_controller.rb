class AvatarsController < ApplicationController

  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  def new
    @avatar = Avatar.new
    @user = User.find(params[:user_id])
    render :layout => false
  end
  
  def create
    if params[:avatar] && params[:avatar][:uploaded_data].respond_to?(:size) && params[:avatar][:uploaded_data].size > 0
      @user.avatars.each{|a| a.destroy}
      if @user.avatars << Avatar.create(params[:avatar])
        redirect_to new_user_avatar_path(params[:user_id], :coming_from => 'create')
      end
    else
      flash[:error] = 'Problems uploading your avatar.'
      redirect_to new_user_avatar_path(@user)
    end
  end

private

  def find_user
    @user = User.find(params[:user_id], :conditions => ["activated_at IS NOT NULL"])  
  end  
  
  def check_current_user
    unless current_user == @user
      redirect_to '/' and return
    end
  end
  
end
