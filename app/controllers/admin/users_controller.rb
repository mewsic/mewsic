class Admin::UsersController < Admin::AdminController #:nodoc:
  def index
    @users = User.find(:all, :order => 'id DESC')
  end
  
  def show
    @user = User.find_from_param(params[:id])
  end

  def update
    @user = User.find_from_param(params[:id])
    if @user.update_attributes! params[:user]
      @user.update_attribute :email, params[:user][:email]
      render(:update) { |page| page.hide 'editing' }
    else
      render :action => 'show'
    end
  end
end
