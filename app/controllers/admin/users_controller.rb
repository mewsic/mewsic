class Admin::UsersController < Admin::AdminController
  def index
    @users = User.find(:all, :order => 'id DESC')
  end
  
  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes! params[:user]
      render(:update) { |page| page.hide 'editing' }
    else
      render :action => 'show'
    end
  end
end
