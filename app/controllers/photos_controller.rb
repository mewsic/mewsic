class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable
  before_filter :check_current_user
  before_filter :check_photo_count, :only => [:new, :create]
  
  def new
    @photo = Photo.new
    @last_photo = @pictureable.photos.last if params[:coming_from] == 'create'
    render :layout => false
  end
  
  def create 
    return if @no_upload

    unless params[:photo] && params[:photo][:uploaded_data].respond_to?(:size) && params[:photo][:uploaded_data].size > 0
      raise ArgumentError # XXX
    end

    @photo = Photo.new(params[:photo])
    @photo.pictureable = @pictureable
    @photo.save!
    @saved = true
    flash.now[:notice] = 'Picture uploaded correctly'

  rescue ArgumentError, ActiveRecord::RecordInvalid
    flash.now[:error] = 'Error uploading your photo. Only PNG, GIF and JPEG image types are allowed!'

  ensure
    render :action => 'new', :layout => false
  end

  def destroy 
    @photo = @pictureable.photos.find(params[:id])
    @photo.destroy
    respond_to do |format|
      format.html do
        url = params[:mband_id] ? mband_photos_path(@pictureable) : user_photos_path(@pictureable)
        redirect_to(url)
      end
      format.js
    end
  end

private

  def find_pictureable
    if params[:user_id]
      @pictureable = User.find_from_param(params[:user_id])
      @user = @pictureable
    elsif params[:mband_id]
      @pictureable = Mband.find_from_param(params[:mband_id])  
      @mband = @pictureable
    end
  end  
  
  def check_current_user   
    if params[:user_id]
      redirect_to '/' and return unless current_user == @user
    elsif params[:mband_id]
      redirect_to '/' and return unless @pictureable.members.include?(current_user)
    end
    
  end

  def check_photo_count
    if @pictureable.photos.count > 9
      flash.now[:alert] = "Sorry, you can upload up to 10 images. Remove one you have already uploaded to add more."
      @no_upload = true
    end
  end
  
end
