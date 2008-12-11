# Myousica Users controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This huge controller handles many of the most important functions of the site: users +index+, the signup
# page (+new+ action) and user creation (+create+); the user page (+show+ action) with its editing features
# (the +update+ action); user activation (+activate+); password handling: +forgot_password+, +reset_password+
# and +change_password+; user type switch (+switch_type+ and +firstrun+); user rating (+rate+).
#
# Plus, some utility methods are included: +countries+, +auto_complete_for_message_to+ and +top+.
#
# Login and ownership of the user is required to access the +update+, +switch_type+, +firstrun+ and +change_password+
# actions. +auto_complete_for_message_to+, +top+ and +rate+ have to be called only via XHR instead.
#
class UsersController < ApplicationController    
  
  before_filter :login_required, :only => [:update, :switch_type, :firstrun, :change_password]
  before_filter :check_if_current_user_page, :only => [:update, :switch_type, :firstrun, :change_password]
  before_filter :check_if_already_logged_in, :only => [:new]
  before_filter :redirect_to_root_unless_xhr, :only => [:auto_complete_for_message_to, :top, :rate]
  
  protect_from_forgery :except => :update

  # ==== GET /users
  #
  # Renders the users index page, using User#find_coolest, User#find_best, User#find_prolific
  # User#find_friendliest, User#find_newest, User#find_most_instruments and Mband#find_coolest.
  #
  def index
    @coolest = User.find_paginated_coolest          :limit => 9    
    @best_myousicians = User.find_paginated_best    :page => 1, :per_page => 3    
    @prolific = User.find_paginated_prolific        :limit => 3
    @friendliest = User.find_friendliest            :limit => 1
    @coolest_mbands = Mband.find_coolest            :limit => 1
    @newest = User.find_paginated_newest            :page => 1, :per_page => 3
    @most_instruments = User.find_most_instruments  :limit => 1
  end

  # ==== XHR GET /users/newest?page=N
  #
  # Paginate and render newest users for the topmost page blocks. Called via XHR.
  def newest
    @newest = User.find_paginated_newest :page => params[:page], :per_page => 3
    render :partial => 'newest'
  end
 
  # ==== XHR GET /users/coolest?page=N
  #
  # Paginate and render coolest users for the topmost page blocks. Called via XHR. 
  def coolest
    @coolest = User.find_paginated_coolest :page => params[:page], :per_page => 9
    render :partial => 'coolest'
  end

  # ==== XHR GET /users/prolific?page=N
  #
  # Paginate and render most prolific users for the topmost page blocks. Called via XHR.
  def prolific
    @prolific = User.find_paginated_prolific :page => params[:page], :per_page => 3
    render :partial => 'prolific'
  end
  
  # ==== XHR GET /users/best?page=N
  #
  # Paginate and render best myousicians for the topmost page blocks. Called via XHR.
  def best
    @best_myousicians = User.find_paginated_best_bands_and_deejays :page => params[:page], :per_page => 3
    render :partial => 'best'
  end

  # ==== GET /signup
  # ==== GET /users/new
  #
  # Renders the signup page.
  #
  def new
    @user = User.new
  end

  # ==== POST /users
  #
  # Creates a new user, and lets the UserObserver send out an activation link via e-mail.
  # If any validation fails, the signup page (<tt>new.html.erb</tt>) is rendered with
  # the resulting errors.
  #
  def create
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    @user.save!

    flash[:notice] = "Thanks for signing up. You will receive a mail with your activation link."
    redirect_to root_url
    # self.current_user = @user
    # redirect_back_or_default('/')
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  # ==== GET /users/:id
  # ==== GET /users/:id.xml
  #
  # * HTML format: renders the user own page, tracks the profile view using User#profile_viewed_by,
  #   renders a listing of user songs while skipping empty ones (see Song#find_paginated_by_user)
  #   and shows user's answers.
  #
  #   If the user is navigating its own page, it sees all the tracks it has uploaded on the site,
  #   pending mband invitations and all mbands even if they're composed of only one member.
  #   If the user navigates another user page, it sees only idea tracks, no mband invitations and
  #   only mbands with more than one member.
  #
  #   If the <tt>welcome</tt> parameter is passed, the <tt>public/javascripts/user/firstrun.js</tt>
  #   javascript code is run, that shows the +firstrun+ action into a <tt>Lightview</tt>.
  #
  # * XML format: renders some user information, as defined by the <tt>show.xml.erb</tt> template.
  #
  def show
    @user = User.find_from_param(params[:id], :include => :avatars)

    respond_to do |format|
      format.html do
        current_user_page = current_user == @user

        @user.profile_viewed_by(tracked_user) unless current_user_page
        @songs = Song.find_paginated_by_user(1, @user, :skip_blank => !current_user_page)
        @songs_count = @user.songs_count(:skip_blank => !current_user_page)
        @answers = @user.answers.paginate(:page => 1, :per_page => 6, :order => 'created_at DESC')
        @new_membership = MbandMembership.new

        @tracks, @tracks_count, @mbands = 
          if current_user_page
            @mband_invitations = @user.pending_mband_invitations
            [Track.find_paginated_by_user(1, @user), @user.tracks_count, @user.mbands]
          else
            [Track.find_paginated_ideas_by_user(1, @user), @user.ideas_count, @user.mbands_with_more_than_one_member]
          end

        @firstrun = current_user_page && params.include?(:welcome)
        @has_abuse = @user.abuses.exists? ['user_id = ?', current_user.id] if logged_in?
      end

      format.xml
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'User not found..'
    redirect_to '/'
  end
  
  # ==== GET /activate/:activation_code
  #
  # Processes the initial user activation: a link with a valid activation_code is sent out in the
  # signup e-mail. If the code is valid, the user is logged in, activated and redirected to its
  # own page with the <tt>?welcome</tt> parameter added, that will trigger the first run welcome.
  # If the code is not valid, the user is redirected to '/'.
  #
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      redirect_to(user_path(self.current_user) + '?welcome')
    else
      redirect_to '/'
    end
  end

  # ==== GET /users/:id/firstrun
  #
  # Shows the <tt>users/switch/_firstrun.html.erb</tt> template to the user, that gives it a
  # warm welcome to Myousica and informs it about the different user types. The user can then
  # switch types and start its myousica experience :-).
  #
  def firstrun
    @user = User.find_from_param(params[:id])
    render :template => 'users/switch/firstrun', :layout => false
  end
  
  # ==== PUT /users/:id
  #
  # Updates an user record with the given parameters. An user can change only its own data,
  # because this method has got the +check_if_current_user_page+ filter attached.
  #
  # If updating a single attribute, this action renders the new value of it.
  # If updating multiple ones, nothing is rendered with a 200 status.
  #
  def update
    @user = User.find_from_param(params[:id])
    if @user.update_attributes(params[:user])
      @user.reload
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
  
  # ==== XHR POST /forgot_password
  #
  # Calls the User#forgot_password method if given a correct email address in the POST
  # parameters. The HTML output format redirects to '/' and is currently unused,, the
  # JS one adds shows the user the <tt>flash</tt> contents using the  <tt>Message</tt>
  # object (see <tt>public/javascripts/flash.js</tt>).
  #
  # A password reset link to the user e-mail address is sent if successful.
  #
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

  # ==== GET /reset_password/:id
  # ==== POST /reset_password
  #
  #  * <tt>GET</tt>: This action shows the password reset form if a valid password reset code
  #    has been passed as the <tt>id</tt> parameter.
  #  * <tt>POST</tt>: This action tries to update the user password from the provided one, as
  #    long as it matches the confirmation and the user object passes the validation.
  #    If successful, the action redirects to the current user own page, if it fails, errors
  #    are shown in the flash.
  #
  #  If an invalid reset code is entered, the user is redirected to '/' with an error message
  #  that asks it to try again.
  #
  def reset_password
    @user = User.find_by_password_reset_code(params[:id]) or raise
    return if request.get?

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
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)"
    redirect_to '/'
  end

  # ==== PUT /users/:id/change_password
  #
  # This action makes user able to change their passwords, it is called from the "Personal informations"
  # block on the user page. If the password change succeeds, a flash notice is shown to the user. If it
  # fails, validation errors are spit out in a flash error message.
  #
  def change_password
    user = params[:user]
    if user[:password].blank? || user[:password_confirmation].blank?
      flash[:error] = "you did not provide a new password"
    else
      current_user.password = user[:password]
      current_user.password_confirmation = user[:password_confirmation]

      if current_user.save
        flash[:notice] = "your password has been changed!"
      else
        flash[:error] = current_user.errors.to_a.join(' ')
      end
    end

    redirect_to user_url(current_user)
  end
  
  # ==== GET /users/:id/switch_type
  # ==== PUT /users/:id/switch_type
  #
  #  * <tt>GET</tt>: shows one of the <tt>app/views/users/switch/*_to_*.erb</tt> partials, depending
  #    on which class the user is currently and the desired destination type.
  #  * <tt>PUT</tt>: updates the user's type using the <tt>type</tt> param. It currently can be one
  #    of [User, Dj, Band].
  #
  def switch_type
    @user = User.find_from_param(params[:id])
    @type = %W(user dj band).include?(params[:type]) && params[:type].capitalize

    if !@type #|| @user.class.name == @type
      render :partial => 'users/switch/failure', :status => :bad_request and return
    end

    render :nothing => true, :status => :bad_request and return if request.post? || request.delete?

    respond_to do |format|
      switch_partial = {:partial => "users/switch/#{@user.class.name.downcase}_to_#{@type.downcase}", :layout => 'users/switch/layout'}
      if request.put?
        @user.nickname = params[:nickname] if params[:nickname]
        if @user.switch_to! @type
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
  
  # ==== PUT /users/:id/rate
  #
  # Rates the given user, if User#rateable_by returns true when passed the current user and
  # prints out the number of votes if successful. Nothing is rendered with a 400 status otherwise.
  #
  def rate    
    @user = User.find_from_param(params[:id])
    if @user.rateable_by?(current_user)
      @user.rate(params[:rate].to_i, current_user)
      render :layout => false, :text => "#{@user.rating_count} votes"
    else
      render :nothing => true, :status => :bad_request
    end
  end

  # ==== GET /countries.js
  # ==== GET /countries.xml
  #
  # * JS format: prints a JSON representation of ActionView::Helpers::FormOptionsHelper::COUNTRIES
  # * XML format: renders a simple XML yielding all the countries that have got at least 1 user (see
  #   User#find_countries).
  #
  def countries
    respond_to do |format|
      format.js do
       render :text => ActionView::Helpers::FormOptionsHelper::COUNTRIES.to_json
      end
      format.xml do
        @countries = User.find_countries
      end
    end
  end

  # ==== GET /users/auto_complete_for_message_to
  #
  # Helper action used by the To: field when composing a new message. Yields an &lt;ul&gt; HTML element containing
  # users whose logins match the string passed in <tt>params[:message][:to]</tt>.
  #
  def auto_complete_for_message_to
    q = params[:message][:to] if params[:message]
    render :nothing => true if q.blank?
    @users = User.find(:all, :order => "login ASC", :conditions => ["login LIKE ?", "%#{q}%"], :limit => 10)
    render :inline => "<%= content_tag(:ul, @users.map { |u| content_tag(:li, h(u.login)) }) %>"
  end

  # ==== GET /users/top
  #
  # Renders one of the four <tt>most_friends</tt>, <tt>most_admirers</tt>, <tt>most_instruments</tt>
  # or <tt>coolest</tt> partials for User or Mbands. This action is used by the blue refresh arrows
  # on user and bands&deejays listings, in order to show a randomly picked "top" user.
  #
  def top
    if [:class, :type].any? { |p| params[p].blank? }
      render :nothing => true, :status => :bad_request and return
    end

    unless %(user band mband).include?(params[:class]) &&
      %(friend admirer instrument cool).include?(params[:type])
      render :nothing => true, :staus => :bad_request and return
    end

    model = (params[:class] == 'mband') ? Mband : User
    method, partial = {
      'friend'     => ['find_friendliest',      'most_friends'],
      'admirer'    => ['find_most_admired',     'most_admirers'],
      'instrument' => ['find_most_instruments', 'most_instruments'],
      'cool'       => ['find_coolest',          'coolest']
    }.fetch(params[:type])

    method += '_band_or_deejays' if params[:class] == 'band'
    render :nothing => true, :status => :bad_request and return unless model.respond_to? method

    partial = model.name.downcase.pluralize + '/' + partial
    object = model.send(method, :limit => 10).sort_by{rand}.first # ugh. heavy.

    render :nothing => true, :status => :ok and return unless object
    render :partial => partial, :object => object
  end

protected

  # Filter that checks whether the user is browsing its own page
  #
  def check_if_current_user_page
    redirect_to('/') and return unless (current_user.id == User.from_param(params[:id])) || current_user.is_admin?
  end

  # Filter that checks whether an user is logged in XXX FIXME remove this
  #
  def check_if_already_logged_in
    redirect_to(user_url(current_user)) if logged_in?
  end
  
  # Helper that generates the breadcrumb link. If the user is navigating the index,
  # "People" is shown with no link. If the <tt>@user</tt> is a new record, this is
  # a "Sign up". In other cases, "User", "Band" or "DJ" is shown with the link to
  # the respective index (<tt>users_path</tt> or <tt>bands_and_deejays_path</tt>).
  #
  def to_breadcrumb_link
    case @user.class.name
    when 'NilClass'
      ['People', nil]
    when 'User'
      if @user.new_record?
        ['Sign up', nil]
      else
        ['User', users_path]
      end
    when 'Band'
      ['Band', bands_and_deejays_path]
    when 'Dj'
      ['DJ', bands_and_deejays_path]
    end
  end
end
