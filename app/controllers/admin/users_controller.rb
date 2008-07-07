class Admin::UsersController < Admin::AdminController
  def index
    @users = User.find(:all, :order => 'id')
  end
  
  def show
    @user = User.find_from_param(params[:id])
  end

  def update
    @user = User.find_from_param(params[:id])
    @user.update_attributes! params[:user]
    render :action => 'show'
  end
end
