class BandMembersController < ApplicationController
  
  layout nil
  
  before_filter :find_user
  before_filter :login_required
  before_filter :check_if_current_user_page
  before_filter :check_if_band  

  def index
    if @user.members.size > 0
      render :partial => 'users/band_member', :collection => @user.members
    else
      render :partial => 'users/no_band_members'
    end
  end

  def new
    @member = BandMember.new
    render :partial => 'users/my/band_member_form'
  end
  
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

  def destroy
    @member = @user.members.find(params[:id])
    @member.destroy

    render :nothing => true, :status => :ok
   
  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
  end  

protected
  
  def find_user
    @user = User.find_from_param(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to('/')
  end
  
  def check_if_current_user_page
    redirect_to('/') and return unless @user.id == current_user.id || current_user.is_admin?
  end
  
  def check_if_band
    redirect_to('/') and return unless @user.read_attribute(:type) == 'Band'
  end

private

  def link_to_user_if_myousica_id!
    @member.unlink!

    if @member.nickname.strip =~ /^\d+$/ # this is a myousica ID, try to find an user..
      @member.link_to(User.find(@member.nickname))

    else # this is a bare member

      unless params[:band_member_avatar_id].blank?
        @member.avatars.each(&:destroy)
        @member.avatars << Avatar.find(params[:band_member_avatar_id])
      end
    end
  end
end
