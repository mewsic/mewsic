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
      @avatar = Avatar.new(params[:avatar].merge({:pictureable => current_user}))      
      if @avatar.save
        @saved = true
        flash.now[:notice] = 'Image uploaded correctly'
      end
    else
      flash.now[:error] = 'Error uploading your image'
    end
    render :action => 'new', :layout => false
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
