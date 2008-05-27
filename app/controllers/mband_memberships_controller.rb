class MbandMembershipsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_mband, :only => :create

  def create        
    redirect_to '/' unless @mband.members.include?(current_user)    
    @user = User.find(params[:user_id])    
    unless MbandMembership.find(:first, :conditions => ["user_id = ? AND mband_id = ?", @user.id, @mband.id])
      MbandMembership.create(:user => @user, :mband => @mband)
    end
    
    flash[:notice] = "User #{@user.login} has been invited to the #{@mband.name} mband"
    redirect_to mband_url(@mband)
  end

  def destroy
    @membership = MbandMembership.find(params[:id])
    redirect_to '/' unless @membership.mband.members.include?(current_user)
    @membership.destroy
    
    respond_to do |format|
      format.js
    end
  end
  
  def accept
    @membership = MbandMembership.find(:first, :conditions => ["membership_token = ?", params[:token]])
    @membership.update_attribute(:accepted_at, Time.now)
    flash[:notice] = "Invitation has been accepted"
    redirect_to mband_url(@membership.mband)
  end

private

  def find_mband    
    if params[:mband_id].blank? || params[:mband_id] == '0'                  
      @mband = Mband.create(:name => params[:mband_name])      
      membership = MbandMembership.new(:mband => @mband, :user => current_user)
      membership.accepted_at = Time.now
      membership.save
    else
      @mband = current_user.mbands.find(params[:mband_id])
    end    
  end    
  
end
