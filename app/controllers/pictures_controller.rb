class PicturesController < ApplicationController
  
  before_filter :find_user
  before_filter :check_current_user, :only => [:create, :destroy]  
  
  def index
    @pictures = @user.pictures
  end

  def create
    if @user.pictures.create(params[:picture])
      respond_to do |format|
        format.html { redirect_to user_pictures_path(@user) }
      end
    end
  end

  def destroy
    @user.pictures.find(params[:id]).destroy and redirect_to(user_picture_path(@user))
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
