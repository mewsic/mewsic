class UsersController < ApplicationController
  
  def index
    # FIXME: bisogna recuperare solo gli utenti attivati
    @coolest = User.find_coolest :limit => 9
    @best_myousicians = User.find_best_myousicians :limit  => 3
    @prolific = User.find_prolific :limit => 3
    @friendliest = User.find_friendliest :limit => 1
    @most_bands = User.find_most_banded :limit => 1
    @newest = User.find_newest :limit => 3
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    # self.current_user = @user
    # redirect_back_or_default('/')
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def show
    @user = User.find(params[:id], :conditions => ["activated_at IS NOT NULL", nil], :include => { :songs => [:tracks, :genre] })
  rescue ActiveRecord::RecordNotFound
    redirect_to '/'
  end
  
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      redirect_to user_path(self.current_user)
    else
      redirect_to '/'
    end
  end
  
  protected
  def to_breadcrumb
    "People"
  end
end
