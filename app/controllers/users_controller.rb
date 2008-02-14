class UsersController < ApplicationController    
  
  before_filter :login_required, :only => :update
  before_filter :check_if_current_user_page, :only => :update
  
  protect_from_forgery :except => :update
  
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
    @user = User.find(params[:id], :conditions => ["activated_at IS NOT NULL", nil])
    # non uso :include => [{:songs => [:tracks, :genre]}] xkè non devo recuperare tutte le tracce
    @songs  = @user.songs.find(:all, :order => 'title ASC', :limit => 3)
    @tracks = Track.find(:all, :limit => 10, :order => "tracks.title ASC", :include => [{:songs => :user}], :conditions => ["users.id = ?", @user.id])
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
  
  def update
    @user = User.find(params[:id])
    # FIXME: cambiare l'output a seconda del formato richiesto e se ci sono errori.
    if @user.update_attributes(params[:user])
      if params[:user] && params[:user].keys.size == 1
        render(:text => @user.send(params[:user].keys.first)) and return
      end
      render :layout => false
    else      
    end
  rescue ActiveRecord::RecordNotFound
  end
  
  protected
  
  def check_if_current_user_page
    redirect_to('/') and return unless current_user.id == params[:id].to_i
  end
  
  def to_breadcrumb
    "People"
  end
end
