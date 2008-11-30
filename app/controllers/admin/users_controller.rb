class Admin::UsersController < Admin::AdminController #:nodoc:
  before_filter :find_user, :except => :index

  def index
    @users = User.find(:all, :order => 'id DESC')
  end
  
  def show
  end

  def update
    if @user.update_attributes! params[:user]
      @user.update_attribute :email, params[:user][:email]
      @user.update_attribute :activated_at, params[:user][:activated_at]

      render(:update) { |page| page.hide 'editing' }
    else
      render :action => 'show'
    end
  end

  protected
  def find_user
    @user = User.find_by_login(params[:id]) || User.find(params[:id])
  end
end
