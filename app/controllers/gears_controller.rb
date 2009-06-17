class GearsController < ApplicationController
  before_filter :login_required
  before_filter :check_current_user

  def sort
    Gear.sort(params[:gears])
    head :ok
  end

  private
    def check_current_user
      @user = User.find(params[:user_id])
      head :forbidden unless @user == current_user
    end
end
