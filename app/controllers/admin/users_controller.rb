class Admin::UsersController < Admin::AdminController
  def index
    @users = User.find(:all, :order => 'id DESC')
  end
  
  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes! params[:user]
    render :action => 'show'
  end
end
