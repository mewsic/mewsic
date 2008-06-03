class MbandMembershipsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_mband, :only => :create

  def create        
    @user = User.find_from_param(params[:user_id])    
    if @mband.nil? || !@mband.valid?
      flash[:error] = "Invalid M-band"
      flash[:error] << ": #{@mband.errors.map(&:last).join}" unless @mband.nil?
      redirect_to user_url(@user) and return
    end

    redirect_to '/' and return unless @mband.members.include?(current_user)    

    unless MbandMembership.find(:first, :conditions => ["user_id = ? AND mband_id = ?", @user.id, @mband.id])
      MbandMembership.create(:user => @user, :mband => @mband)
    end
    
    flash[:notice] = "User '#{@user.login}' has been invited to the '#{@mband.name}' M-band!"
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
      return unless @mband.valid?

      membership = MbandMembership.new(:mband => @mband, :user => current_user)
      membership.accepted_at = Time.now
      membership.save
    else
      @mband = current_user.mbands.find_from_param(params[:mband_id]) rescue nil
    end
  end    
  
end
