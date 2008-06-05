class AvatarsController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable
  before_filter :check_current_user

  def update
    unless valid_file_upload?(:avatar)
      render :nothing => true, :status => :bad_request and return
    end

    @avatar = Avatar.new(params[:avatar].merge({:pictureable => @pictureable}))
    respond_to do |format|
      if @avatar.valid?
        @pictureable.avatars.each(&:destroy)
        @avatar.save!

        format.html { redirect_to user_url(current_user) }
        format.js do
          responds_to_parent do
            render :update do |page|
              page['user-avatar-image'].src = @avatar.public_filename(:big)
              page << %[UserAvatar.instance.uploadCompleted();]
            end
          end
        end
      else
        format.html do
          flash[:error] = @avatar.errors.full_messages.join("\n")
          redirect_to user_url(current_user) 
        end

        format.js do
          responds_to_parent do
            render :update do |page|
              # TODO: These messages should go into a tooltip, once they're implemented
              #page['change-avatar-alert'].innerHTML = @avatar.errors.full_messages.join(",")
              page << %[UserAvatar.instance.uploadFailed();]
            end
          end
        end
      end
    end
  end

private

  def find_pictureable
    if params[:user_id]
      @pictureable = User.find_from_param(params[:user_id])
    elsif params[:mband_id]
      @pictureable = Mband.find_from_param(params[:mband_id])  
    end
  end  

  def check_current_user
    if params[:user_id]
      redirect_to '/' and return unless current_user == @pictureable
    elsif params[:mband_id]
      redirect_to '/' and return unless @pictureable.members.include?(current_user)
    end                
  end

end
