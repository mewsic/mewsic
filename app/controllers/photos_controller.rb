class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  def new
    @photo = Photo.new
    @last_photo = @user.photos.last   if params[:coming_from] == 'create'
    render :layout => false
  end
  
  def create 
    if params[:photo] && params[:photo][:uploaded_data].respond_to?(:size) && params[:photo][:uploaded_data].size > 0
      @photo = Photo.new(params[:photo].merge(:user_id => current_user.id))
      if @photo.save
        @saved = true
        flash.now[:notice] = 'Picture uploaded correctly'
      end
    else
      flash.now[:error] = 'Problems uploading your photo.'
    end
    render :action => 'new', :layout => false
  end

  def destroy
    @user.photos.find(params[:id]).destroy and redirect_to(user_photos_path(@user)) 
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
