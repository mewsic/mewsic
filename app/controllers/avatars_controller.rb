class AvatarsController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable,   :only => :update
  before_filter :check_current_user, :only => :update
  before_filter :check_file_upload,  :only => [:create, :update]

  def create
    @avatar = Avatar.create(params[:avatar])

    respond_to do |format|
      format.js do
        responds_to_parent do
          render :update do |page|
            if @avatar.valid?
              page << %[BandMembers.instance.uploadCompleted(#{@avatar.id}, "#{@avatar.public_filename(:icon)}")]
            else
              page << %[BandMembers.instance.uploadFailed()]
            end
          end
        end
      end
    end

  end

  def update
    @avatar = Avatar.new(params[:avatar].merge({:pictureable => @pictureable}))
    respond_to do |format|
      if @avatar.valid?
        @pictureable.avatars.each(&:destroy)
        @avatar.save!

        format.html { redirect_to user_url(current_user) }
        format.js do
          responds_to_parent do
            render :update do |page|
              page << %[UserAvatar.instance.uploadCompleted("#{@avatar.public_filename(:big)}");]
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

  def destroy
    @avatar = Avatar.find(params[:id])

    # destroy only unbound avatars
    raise ActiveRecord::RecordNotFound if @avatar.thumbnail? || !@avatar.pictureable.nil?

    @avatar.destroy
    render :nothing => true, :status => :ok

  rescue ActiveRecord::ActiveRecordError
    render :nothing => true, :status => :bad_request
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
      redirect_to '/' and return unless current_user == @pictureable || current_user.is_admin?
    elsif params[:mband_id]
      redirect_to '/' and return unless @pictureable.members.include?(current_user)
    end                
  end

  def check_file_upload
    unless valid_file_upload?(:avatar)
      render :nothing => true, :status => :bad_request and return
    end
  end

end
