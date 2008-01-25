class UsersController < ApplicationController
  
  def index
    @coolest = User.find_coolest :limit => 9
    @best_myousicians = User.find_best_myousicians :limit  => 3
    @prolific = User.find_prolific :limit => 3
    @friendliest = User.find_friendliest :limit => 1
    @most_bands = User.find_most_banded :limit => 1
    @newest = User.find_newest :limit => 3
  end

  # render new.rhtml
  def new
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  protected
  def breadcrumb
    "People"
  end
end
