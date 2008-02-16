class AvatarsController < ApplicationController

  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  def index
    @avatar = Avatar.new
    @avatar = @user.avatars.last   if params[:coming_from] == 'create'
    render :layout => false
  end
  
  def create 
    if params[:avatar] && params[:avatar][:uploaded_data].respond_to?(:size) && params[:avatar][:uploaded_data].size > 0
      if @user.avatars.create(params[:avatar])
        redirect_to :action => 'index', :user_id => params[:user_id], :coming_from => 'create'
      end
    else
      flash[:error] = 'Problems uploading your avatar.'
      redirect_to user_avatars_path(@user)
    end
  end

  def destroy
    @user.avatars.find(params[:id]).destroy and redirect_to(user_avatars_path(@user))
  rescue ActiveRecord::RecordNotFound
    redirect_to '/'
  end

private

  def find_user
    @user = User.find(params[:user_id], :conditions => ["activated_at IS NOT NULL"])
  rescue ActiveRecord::RecordNotFound
    redirect_to '/'    
  end  
  
  def check_current_user
    unless current_user == @user
      redirect_to '/' and return
    end
  end
  
end
