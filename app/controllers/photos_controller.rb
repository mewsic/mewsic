class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable
  before_filter :check_current_user
  before_filter :check_photo_count, :only => :create
  
  def index
    redirect_to_pictureable_path
  end

  def create 
    unless valid_file_upload?(:photos)
      render :nothing => true, :status => :bad_request and return
    end

    respond_to do |format|
      if @upload_limit
        format.js do
          responds_to_parent do
            render(:update) { |page| page << %[GalleryUpload.instance.uploadLimitReached(#@upload_limit)] }
          end
        end
      else
        @photo = Photo.new(params[:photos])
        @photo.pictureable = @pictureable

        if @photo.save
          format.js do
            responds_to_parent { render }
          end
        else
          format.js do
            responds_to_parent do
              render(:update) { |page| page << %[GalleryUpload.instance.uploadFailed()] }
            end
          end
        end
      end
    end
  end

  def destroy 
    @photo = @pictureable.photos.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to_pictureable_path }
      format.js
    end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found
  end

private

  def find_pictureable
    if params[:user_id]
      @pictureable = User.find_from_param(params[:user_id])
      @user = @pictureable
    elsif params[:mband_id]
      @pictureable = Mband.find_from_param(params[:mband_id])  
      @mband = @pictureable
    else
      redirect_to '/'
    end
  end  
  
  def check_current_user   
    if params[:user_id]
      redirect_to '/' and return unless (current_user == @user) || current_user.is_admin?
    elsif params[:mband_id]
      redirect_to '/' and return unless @mband.members.include?(current_user) || current_user.is_admin?
    end
  end

  def check_photo_count
    if @pictureable.photos.count > 9
      @upload_limit = 10
    end
  end

  def redirect_to_pictureable_path
    redirect_to(params[:mband_id] ? mband_path(@pictureable) : user_path(@pictureable))
  end
  
end
