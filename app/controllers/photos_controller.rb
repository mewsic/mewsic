class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  def new
    @photo = Photo.new
    flash[:alert] = "Sorry, you can upload up to 10 images. Remove one you have already uploaded to have had one more." if @user.photos.count > 9
    @last_photo = @user.photos.last   if params[:coming_from] == 'create'
    render :layout => false
  end
  
  def create 
    if @user.photos.count > 9
      flash[:alert] = "Sorry, you can upload up to 10 images. Remove one you have already uploaded to have had one more." 
    else
      if params[:photo] && params[:photo][:uploaded_data].respond_to?(:size) && params[:photo][:uploaded_data].size > 0
        @photo = Photo.new(params[:photo])
        @photo.pictureable = current_user
        if @photo.save
          @saved = true
          flash.now[:notice] = 'Picture uploaded correctly'
        end
      else
        flash.now[:error] = 'Problems uploading your photo.'
      end
    end    
    render :action => 'new', :layout => false
  end

  def destroy
    @photo = @user.photos.find(params[:id])
    @photo.destroy
    
    respond_to do |format|
      format.html { redirect_to(user_photos_path(@user)) }
      format.js
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
