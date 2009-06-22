class GearsController < ApplicationController
  before_filter :login_required, :except => :index
  before_filter :check_current_user
  before_filter :check_create_parameters, :only => :create

  def index
    render :partial => 'users/gear', :collection => @user.gears
  end

  def create
    if params[:gear]
      user_gears = @user.gears.to_a

      params[:gear].each do |id, attributes|
        gear = user_gears.find { |g| g.id == id.to_i }
        gear.update_attributes(attributes) if gear
      end

      # Remove deleted items
      submitted = params[:gear].keys.map(&:to_i)
      user_gears.select { |g| !submitted.include?(g.id) }.each(&:destroy)
    end

    if params[:new_gear]
      params[:new_gear].to_a.reverse.each do |foo, attributes|
        gear = @user.gears.create(attributes)
        gear.move_to_top
      end
    end

    render :partial => 'users/gear', :collection => @user.reload.gears

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
      head :bad_request unless [:gear, :new_gear].any? do |h|
        params[h] && params[h].all? do |id, gear|
          gear[:model] && gear[:brand] && gear[:instrument_id]
        end
      end
    end
end
