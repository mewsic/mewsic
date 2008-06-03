class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  before_filter :check_photo_count, :only => [:new, :create]
  
  def new
    @photo = Photo.new
    @last_photo = @user.photos.last   if params[:coming_from] == 'create'
    render :layout => false
  end
  
  def create 
    return if @no_upload

    unless params[:photo] && params[:photo][:uploaded_data].respond_to?(:size) && params[:photo][:uploaded_data].size > 0
      raise ArgumentError # XXX
    end

    @photo = Photo.new(params[:photo])
    @photo.pictureable = current_user
    @photo.save!
    @saved = true
    flash.now[:notice] = 'Picture uploaded correctly'

  rescue ArgumentError, ActiveRecord::RecordInvalid
    flash.now[:error] = 'Error uploading your photo. Only PNG, GIF and JPEG image types are allowed!'

  ensure
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
    @user = User.find_from_param(params[:user_id])
  end  
  
  def check_current_user
    unless current_user == @user
      redirect_to '/' and return
    end
  end

  def check_photo_count
    if @user.photos.count > 9
      flash.now[:alert] = "Sorry, you can upload up to 10 images. Remove one you have already uploaded to add more."
      @no_upload = true
    end
  end
  
end
