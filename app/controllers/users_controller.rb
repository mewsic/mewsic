class UsersController < ApplicationController    
  
  before_filter :login_required, :only => :update
  before_filter :check_if_current_user_page, :only => [:update, :switch_type]
  before_filter :check_if_already_logged_in, :only => [:new]
  
  protect_from_forgery :except => :update

  helper :band_members
  
  def index
    @coolest = User.find_coolest
    # TODO: al momento find_best_myousicians tira fuori le canzoni per non avere persone senza canzoni
    @best_myousicians = User.find_best_myousicians :limit  => 3
    @prolific = User.find_prolific :limit => 3
    @friendliest = User.find_friendliest :limit => 1
    @most_bands = [] #User.find_most_banded :limit => 1
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
    flash[:notice] = "Thanks for signing up. You will receive a mail with your activation link."
    redirect_to root_url
    # self.current_user = @user
    # redirect_back_or_default('/')
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def show
    @user = User.find_from_param(params[:id], :include => [:avatars])
    # non uso :include => [{:songs => [:tracks, :genre]}] xkè non devo recuperare tutte le tracce
    @songs = Song.find_paginated_by_user(1, @user)
    @tracks = Track.find_paginated_by_user(1, @user)    
    @answers = @user.answers.paginate(:page => 1, :per_page => 6, :order => 'created_at DESC')  
    @new_membership = MbandMembership.new

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'User not found..'
    redirect_to '/'
  end
  
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Welcome aboard, #{self.current_user.login}!"
      redirect_to user_path(self.current_user)
    else
      redirect_to '/'
    end
  end
  
  def update
    @user = User.find_from_param(params[:id])
    # FIXME: cambiare l'output a seconda del formato richiesto e se ci sono errori.
    if @user.update_attributes(params[:user])
      if params[:user] && params[:user].keys.size <= 2
        render(:text => @user.send(params[:user].keys.first)) and return
      end
      render :nothing => true
    else
      render :text => @user.errors.map(&:last).join("\n"), :status => :bad_request
    end  

  rescue NoMethodError # non existing field
    render :nothing => true, :status => :bad_request
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
  
  def switch_type
    redirect_to '/' and return unless request.xhr?

    @user = User.find_from_param(params[:id])
    @type = %W(user dj band).include?(params[:type]) && params[:type].capitalize

    if !@type || @user.class.name == @type
      render :partial => 'users/switch/failure', :status => :bad_request and return
    end

    render :nothing => true, :status => :bad_request if request.post? || request.delete?

    respond_to do |format|
      switch_partial = {:partial => "users/switch/#{@user.class.name.downcase}_to_#{@type.downcase}", :layout => 'users/switch/layout'}
      if request.put?
        @user.nickname = params[:nickname]
        if @user.update_attribute(:type, @type)
          format.html { render :partial => "users/switch/success" }
        else
          flash.now[:error] = @user.errors.full_messages.join
          format.html { render switch_partial }
        end
      else
        format.html { render switch_partial }
      end
    end
  end
  
  def request_config
    @user = User.find_from_param(params[:user_id])
    respond_to do |format|
      format.xml
    end
  end  
  
  def rate    
    @user = User.find_from_param(params[:id])
    @user.rate(params[:rate].to_i, current_user)
    render :layout => false, :text => "#{@user.rating_count} votes"
  end

  def countries
    render :json => ActionView::Helpers::FormOptionsHelper::COUNTRIES
  end
  
  def auto_complete_for_message_to
    q = params[:message][:to] if params[:message]
    return :inline => '' if q.blank?
    @users = User.find(:all, :order => "login ASC", :conditions => ["login LIKE ?", "%#{q}%"])
    render :inline => "<%= content_tag(:ul, @users.map { |u| content_tag(:li, h(u.login)) }) %>"
  end

  def im_contact
    redirect_to root_url and return unless request.xhr?
    raise ActiveRecord::RecordNotFound unless %w(skype msn).include?(params[:type])

    user = User.find_from_param(params[:id])
    @im = params[:type]
    @handle = user[@im]

    raise ActiveRecord::RecordNotFound if @handle.blank? || !user.send("#{@im}_public?")
    render :partial => 'users/im'

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found
  end
  
protected
  
  def check_if_current_user_page
    redirect_to('/') and return unless current_user.id == User.from_param(params[:id])
  end

  def check_if_already_logged_in
    redirect_to(user_url(current_user)) if logged_in?
  end
  
  def to_breadcrumb_link
    if @user and [Band, Dj].include? @user.class
      ['Bands &amp; deejays', bands_and_deejays_path]
    else
      ['People', users_path]
    end
  end
end
