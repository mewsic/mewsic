class BandMembersController < ApplicationController
  
  layout nil
  
  before_filter :find_user
  before_filter :login_required
  before_filter :check_if_current_user_page
  before_filter :check_if_band  

  def index
    render :partial => 'users/band_member', :collection => @user.members
  end

  def new
    @member = BandMember.new
    render :partial => 'users/my/band_member_form'
  end
  
  def create
    @member = BandMember.new(params[:band_member])    
    @member.user = @user
    @member.save!

    render :partial => 'users/my/band_member', :object => @member

  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
  end

  def update
    @member = BandMember.find(params[:id])
    @member.update_attributes!(params[:band_member])

    render :partial => 'users/my/band_member', :object => @member

  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
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
    redirect_to('/') and return unless @user.id == current_user.id
  end
  
  def check_if_band
    redirect_to('/') and return unless @user.read_attribute(:type) == 'Band'
  end

end
