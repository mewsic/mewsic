class MbandMembershipsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_mband, :only => :create

  def create        
    @user = User.find_from_param(params[:user_id])    
    @instrument = Instrument.find(params[:instrument_id])

    if @mband.nil? || !@mband.valid?
      flash[:error] = "Invalid M-band"
      flash[:error] << ": #{@mband.errors.map(&:last).join(',')}" unless @mband.nil?
      redirect_to user_url(@user) and return
    end

    redirect_to '/' and return unless @mband.members.include?(current_user)    

    unless MbandMembership.find(:first, :conditions => ["user_id = ? AND mband_id = ?", @user.id, @mband.id])
      MbandMembership.create!(:user => @user, :mband => @mband, :instrument => @instrument)
    end
    
    flash[:notice] = "User '#{@user.login}' has been invited to the '#{@mband.name}' M-band as a '#{@instrument.description}' player!"
    redirect_to mband_url(@mband)

  rescue ActiveRecord::ActiveRecordError
    flash[:error] = "Invalid request"
    redirect_to mband_url(@mband)
  end

  def destroy
    @membership = MbandMembership.find(params[:id])
    redirect_to '/' unless @membership.mband.members.include?(current_user)
    @membership.destroy
    
    respond_to do |format|
      format.js
      format.html { redirect_to user_url(current_user) }
    end
  end
  
  def accept
    @membership = MbandMembership.find(:first, :conditions => ["membership_token = ?", params[:token]])
    @membership.accept!

    flash[:notice] = "Invitation has been accepted"
    redirect_to mband_url(@membership.mband)
  end

  def decline
    @membership = MbandMembership.find(:first, :conditions => ["membership_token = ?", params[:token]])
    @membership.destroy

    flash[:notice] = "Invitation has been declined"
    redirect_to user_url(current_user)
  end

private

  def find_mband    
    if params[:mband_id].blank? || params[:mband_id] == '0'
      @mband = Mband.create(:name => params[:mband_name])      
      return unless @mband.valid?
      instrument = Instrument.find(params[:leader_instrument_id])

      membership = MbandMembership.new(:mband => @mband, :user => current_user, :instrument => instrument)
      membership.accept!
    else
      @mband = current_user.mbands.find_from_param(params[:mband_id]) rescue nil
    end
  end    
  
end
