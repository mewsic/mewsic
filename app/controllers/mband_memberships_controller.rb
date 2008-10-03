# Myousica M-Band Memberships Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
# 
# This RESTful controller implements +create+ and +destroy+ operation on MbandMemberships, that
# represent a membership to an Mband.
#
# Memberships are to be confirmed by the recipient and can be declined, the +accept+ and +decline+
# actions accomplish these goals. Login is required for all these actions.
#
class MbandMembershipsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_mband, :only => :create

  # <tt>POST /mband_memberships</tt>
  #
  # Create a new membership between the Mband found in the +find_mband+ filter and the passed
  # <tt>user_id</tt> parameter, as an <tt>instrument_id</tt> player. An user must be a member
  # of the Mband in order to invite others. See the +find_mband+ filter also.
  #
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

  # <tt>DELETE /mband_memberships/:id</tt>
  #
  # Destroys an existing membership, doing the necessary sanity checks. User is redirected
  # to its page upon completion.
  #
  def destroy
    @membership = MbandMembership.find(params[:id])
    redirect_to '/' unless @membership.mband.members.include?(current_user)
    @membership.destroy
    
    respond_to do |format|
      format.js
      format.html { redirect_to user_url(current_user) }
    end
  end
  
  # <tt>GET /mband_memberships/accept/:token</tt>
  #
  # Finds an Mband by accept token and finalize the membership. User is redirected to Mband page upon completion.
  #
  def accept
    @membership = MbandMembership.find(:first, :conditions => ["membership_token = ?", params[:token]])
    @membership.accept!

    flash[:notice] = "Invitation has been accepted"
    redirect_to mband_url(@membership.mband)
  end

  # <tt>GET /mband_memberships/decline/:token</tt>
  #
  # Decline (so, destroy) a membership. User is redirected to its own page upon completion.
  #
  def decline
    @membership = MbandMembership.find(:first, :conditions => ["membership_token = ?", params[:token]])
    @membership.destroy

    flash[:notice] = "Invitation has been declined"
    redirect_to user_url(current_user)
  end

private

  # Filter that searches for an Mband if an <tt>mband_id</tt> parameter is passed. If it is blank
  # or '0', a new Mband is created with the supplied <tt>mband_name</tt> and its creator is automatically
  # promoted as the Mband leader.
  #
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
