class GearsController < ApplicationController
  before_filter :login_required
  before_filter :check_current_user
  before_filter :check_create_parameters, :only => :create

  def create
    user_gears = @user.gears.to_a

    params[:gear].each do |id, attributes|
      gear = user_gears.find { |g| g.id == id.to_i }
      gear.update_attributes(attributes) if gear
    end

    if params[:new_gear]
      params[:new_gear].each do |foo, attributes|
        @user.gears.create(attributes)
      end
    end

    render :partial => 'users/gear', :collection => @user.gears.to_a

  rescue ActiveRecord::ActiveRecordError
    head :bad_request
  end

  def sort
    Gear.sort(params[:gears])
    head :ok
  end

  private
    def check_current_user
      @user = User.find_from_param(params[:user_id])
      head :forbidden unless @user == current_user
    end

    def check_create_parameters
      head :bad_request and return unless params[:gear]
      head :bad_request unless params[:gear].all? do |id, gear|
        gear[:model] && gear[:brand] && gear[:instrument_id]
      end
    end
end
