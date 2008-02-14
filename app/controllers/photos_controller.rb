class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_user
  before_filter :check_current_user
  
  def index
    @photo = Photo.new
  end
  
  def create          
    if params[:photo] && params[:photo][:uploaded_data].respond_to?(:size) && params[:photo][:uploaded_data].size > 0
      if @user.photos.create(params[:photo])
        redirect_to user_photos_path(@user)
      end
    else
      flash[:error] = 'Problems uploading your photo.'
      redirect_to user_photos_path(@user)
    end
  end

  def destroy
    @user.photos.find(params[:id]).destroy and redirect_to(user_photos_path(@user))
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
