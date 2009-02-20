# Myousica Avatars controller.
#
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This RESTful controller handles +create+, +update+ and +destroy+ of an User Avatar.
#
# It is currently hackish, because the +create+ method is only called by the +BandMembersController+
# actions (adding a new member to a Band), while the +update+ method is called from the user page to
# change an User/Dj/Band avatar.
#
# It uses +responds_to_parent+ plugin in order to implement AJAX file uploads.
#
# Login is required to access this controller.
#
class AvatarsController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable,   :only => :update
  before_filter :check_current_user, :only => :update
  before_filter :check_file_upload,  :only => [:create, :update]

  # ==== POST /avatars.js
  #
  # Called by the BandMembers JavaScript widget (see public/javascripts/user/band_members.js)
  # upon the AJAX file upload. Avatars are created unbound, because the file upload completes
  # before actual form submission. The pictureable_id and pictureable_type is filled by the
  # +BandMembersController#link_to_user_if_myousica_id!+ method, called upon creation and
  # update of the BandMember (BandMembersController#create and BandMembersController#update)
  #
  # This action uses the hidden iframe technique (http://www.webtoolkit.info/ajax-file-upload.html)
  # to implement an AJAX file upload, this means that it's called from an hidden iframe so the
  # responds_to_parent plugin eases the task of sending javascript to the parent element of the
  # iframe.
  #
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

  # ==== PUT /users/:user_id/avatar
  # ==== PUT /mbands/:mband_id/avatar
  #
  # Misleading use of RESTful routes, because this action actually creates a new avatar linked to
  # the pictureable found by the +find_pictureable+ method. If the uploaded avatar is valid, the
  # current avatar of the pictureable are destroyed and the new one replaces it.
  # 
  # Like the +update+ method, the responds_to_parent plugin is used to implement an AJAX file upload.
  #
  # This method handles the models specified in the +find_pictureable+ method documentation.
  #
  def update
    @avatar = Avatar.new(params[:avatar].merge({:pictureable => @pictureable}))
    respond_to do |format|
      if @avatar.valid?
        
        if ! @pictureable.avatar.nil?
          @pictureable.avatar.destroy
        end
        
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

  # ==== DELETE /avatars/:id
  #
  # Called by the BandMembers JavaScript widget, when an user changes the avatar of a BandMember.
  # It pays attention to destroy only unbound avatars, e.g. generated when an user repeatedly
  # changes the avatar of a band member before saving it.
  #
  # Bound avatars are destroyed here for the User, Dj and Band models, and into the BandMembersController
  # actions for the BandMember model. Treated differently because they are different beasts.
  #
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

  # Finds a pictureable object, using Rails conventions for parameter names. It handles
  # the User and Mband models.
  #
  def find_pictureable
    if params[:user_id]
      @pictureable = User.find_from_param(params[:user_id])
    elsif params[:mband_id]
      @pictureable = Mband.find_from_param(params[:mband_id])  
    end
  end  

  # Checks that the pictureable object is the current user, or is an admin.
  #
  def check_current_user
    if params[:user_id]
      redirect_to '/' and return unless current_user == @pictureable || current_user.is_admin?
    elsif params[:mband_id]
      redirect_to '/' and return unless @pictureable.members.include?(current_user)
    end                
  end

  # Uses the +valid_file_upload?+ inherited method to check the validity of the upload,
  # and renders nothing with status 400 if it is not valid.
  #
  def check_file_upload
    unless valid_file_upload?(:avatar)
      render :nothing => true, :status => :bad_request and return
    end
  end

end
