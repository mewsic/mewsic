class BandMembersController < ApplicationController
  
  # before_filter :login_required
  # before_filter :check_if_current_user_page
  # before_filter :check_if_band

  def index
    render :text =>  'ciao'
  end
  
  def create
    #@member = BandMember.new(params[:member])
  end

  def update
  end

  def destroy
  end

protected
  
  def check_if_current_user_page
    redirect_to('/') and return unless current_user.id == params[:id].to_i
  end
  
  def check_if_band
    redirect_to('/') and return unless current_user.type == 'Band'
  end

end
