class AvatarsController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable
  before_filter :check_current_user
  
  def new
    render :layout => false
  end
  
  def create    
    if params[:avatar] && params[:avatar][:uploaded_data].respond_to?(:size) && params[:avatar][:uploaded_data].size > 0
      @pictureable.avatars.each{|a| a.destroy}
      @avatar = Avatar.new(params[:avatar].merge({:pictureable => @pictureable}))      
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

  def find_pictureable
    if params[:user_id]
      @pictureable = User.find(params[:user_id], :conditions => ["activated_at IS NOT NULL"])  
    elsif params[:mband_id]
      @pictureable = Mband.find(params[:mband_id])  
    end
  end  
  
  def check_current_user
    if params[:user_id]
      redirect_to '/' and return unless current_user == @pictureable
    elsif params[:mband_id]
      redirect_to '/' and return unless @pictureable.members.include?(current_user)
    end                
  end
  
end
