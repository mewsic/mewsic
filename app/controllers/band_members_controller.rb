# Myousica BandMember Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
# 
# This RESTful controller implements CRUD operations on BandMember instances. Its actions are
# called via XHR by the BandMembers JavaScript widget (see public/javascripts/band_members.js).
#
# To access this controller, a registered Band must be logged in and on its own user page.
#
# A band member can be either a "bare" member, where all the member details are input by the
# user, or can be a "link" to a valid myousica user. See +link_to_user_if_myousica_id+.
#
class BandMembersController < ApplicationController
  
  layout nil
  
  before_filter :find_user
  before_filter :redirect_unless_xhr
  before_filter :login_required
  before_filter :check_if_current_user_page
  before_filter :check_if_band  

  # ==== XHR GET /users/:id/members
  #
  # Renders the contents of the band using the <tt>_band_member.html.erb</tt> template, or the
  # <tt>_no_band_members.html.erb</tt> one if no band members are present. It's called when the
  # user closes editing band mode within the JS widget.
  #
  def index
    if @user.members.size > 0
      render :partial => 'users/band_member', :collection => @user.members
    else
      render :partial => 'users/no_band_members'
    end
  end

  # ==== XHR GET /users/:id/members/new
  #
  # Renders a band member form. Called when entering edit mode from the JS BandMembers widget
  # (see public/javascripts/user/band_members.js).
  #
  def new
    @member = BandMember.new
    render :partial => 'users/my/band_member_form'
  end
  
  # ==== XHR POST /users/:id/members
  #
  # Creates a new BandMember instance and links it to the current user object. It calls
  # +link_to_user_if_myousica_id!+ to check whether this member should be linked to an
  # existing myousica user.
  #
  # In case of failure, an error message is returned as text with a 400 status.
  #
  def create
    @member = BandMember.new params[:band_member]

    link_to_user_if_myousica_id!

    @member.user = @user
    @member.save!

    render :partial => 'users/my/band_member', :object => @member

  rescue ActiveRecord::RecordInvalid
    render :text => 'please insert all fields!', :status => :bad_request
  rescue ActiveRecord::RecordNotFound
    render :text => 'user not found!', :status => :bad_request
  rescue ActiveRecord::ActiveRecordError
    render :text => 'invalid request!', :status => :bad_request
  end

  # ==== XHR PUT /users/:id/members/:id
  #
  # Updates a BandMember instance and calls +link_to_user_if_myousica_id!+ to check
  # whether this member should be linked to an existing myousica user.
  #
  # In case of failure, an error message is returned as text with a 400 status.
  #
  def update
    @member = BandMember.find(params[:id])
    @member.attributes = params[:band_member]

    link_to_user_if_myousica_id!

    @member.save!

    render :partial => 'users/my/band_member', :object => @member

  rescue ActiveRecord::RecordInvalid
    render :text => 'please insert all fields!', :status => :bad_request
  rescue ActiveRecord::RecordNotFound
    render :text => 'user not found!', :status => :bad_request
  rescue ActiveRecord::ActiveRecordError
    render :text => 'invalid request!', :status => :bad_request
  end

  # ==== XHR DELETE /users/:id/members/:member_id
  #
  # Deletes a BandMember instance, rendering nothing with a 200 status.
  # Renders nothing with a 400 status in case of failure.
  #
  def destroy
    @member = @user.members.find(params[:id])
    @member.destroy

    render :nothing => true, :status => :ok
   
  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
  end  

protected
  
  # Filter that requires a valid user id passed in the <tt>user_id</tt> parameter
  # 
  def find_user
    @user = User.find_from_param(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to('/')
  end

  # Filter that redirects to the current user page if the request didn't come through XHR.
  #
  def redirect_unless_xhr
    redirect_to user_path(@user) unless request.xhr?
  end
  
  # Filter that requires an user to be on its own page
  #
  def check_if_current_user_page
    redirect_to('/') and return unless @user == current_user || current_user.is_admin?
  end
  
  # Filter that checks that the kind of the current user is Band
  #
  def check_if_band
    redirect_to('/') and return unless @user.read_attribute(:type) == 'Band'
  end

private

  # A BandMember can be linked to a valid myousica User, if the user passes the user ID
  # as the member nickname. If an user exists with the given ID, it is passed to the
  # BandMember#link_to method; if it does not exist, only the avatar is updated using
  # BandMember#update_avatar.
  #
  def link_to_user_if_myousica_id!
    @member.unlink!

    if @member.nickname.strip =~ /^\d+$/ # this is a myousica ID, try to find an user..
      @member.link_to(User.find(@member.nickname))
    else
      @member.update_avatar(params[:band_member_avatar_id]) unless params[:band_member_avatar_id].blank?
    end
  end
end
