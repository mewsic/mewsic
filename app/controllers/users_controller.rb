class UsersController < ApplicationController    
  
  before_filter :login_required, :only => :update
  before_filter :check_if_current_user_page, :only => :update
  
  protect_from_forgery :except => :update
  
  def index
    @coolest = User.find_coolest :limit => 9
    # TODO: al momento find_best_myousicians tira fuori le canzoni per non avere persone senza canzoni
    @best_myousicians = User.find_best_myousicians :limit  => 3
    @prolific = User.find_prolific :limit => 3
    @friendliest = User.find_friendliest :limit => 1
    @most_bands = User.find_most_banded :limit => 1
    @newest = User.find_newest :limit => 3
    @most_instruments = User.find_with_more_instruments
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
    @user = User.find(params[:id], :conditions => "users.activated_at IS NOT NULL", :include => :avatars)
    @friends = @user.find_friends
    @admirers = @user.find_admirers
    # non uso :include => [{:songs => [:tracks, :genre]}] xkè non devo recuperare tutte le tracce
    @songs = Song.find_paginated_by_user(1, @user.id)
    @tracks = Track.find_paginated_by_user(1, @user.id)
    @gallery = @user.photos.find :all,  :order => "created_at DESC"
    @answers = @user.find_related_answers  
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
  end
  
  def forgot_password    
    if !params[:email].blank? && @user = User.find_by_email(params[:email])
      flash.now[:notice] = "A password reset link has been sent to your email address" 
      @user.forgot_password
      @user.save                 
    else
      flash.now[:error] = "Could not find a user with that email address" 
    end
    
    respond_to do |format|      
      format.html { redirect_to '/' }
      format.js            
    end
  end

  def reset_password
    @user = User.find_by_password_reset_code(params[:id])
    raise if @user.nil?
    return if @user unless params[:password]
      if (params[:password] == params[:password_confirmation])
        self.current_user = @user #for the next two lines to work
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]                
        if current_user.valid? && !params[:password].blank?
          current_user.reset_password
          current_user.save
          flash[:notice] = "Password reset"          
          redirect_to user_path(current_user)
        else
          flash.now[:notice] = "Password too short"
         end        
      else
        flash.now[:notice] = "Password mismatch"         
      end        
  rescue
      logger.error "Invalid Reset Code entered" 
      flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?" 
      redirect_to '/'
  end
    
    
  protected
  
  def check_if_current_user_page
    redirect_to('/') and return unless current_user.id == params[:id].to_i
  end
  
  def to_breadcrumb
    "People"
  end
end
