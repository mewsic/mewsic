# Myousica Photos Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
# 
# This controller interacts with the <tt>Gallery</tt> javascript object located in
# <tt>public/javascripts/user/gallery.js</tt>, and together they implement the user
# gallery. There is no +index+, only +create+ and +destroy+.
#
# Login is required to access this controller, and a valid pictureable id must be
# passed (see +find_pictureable+). Users can only create photos on their own page
# (see +check_current_user+) and there is an upload limit of 10 photos (see
# +check_photo_count+).
#
class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :find_pictureable
  before_filter :check_current_user
  before_filter :check_photo_count, :only => :create
  
  # <tt>GET /users/:user_id/photos</tt>
  # <tt>GET /mbands/:mband_id/photos</tt>
  #
  # Redirects to pictureable path (see +redirect_to_pictureable_path+).
  #
  def index
    redirect_to_pictureable_path
  end

  # <tt>POST /users/:user_id/photos</tt>
  # <tt>POST /mbands/:mband_id/photos</tt>
  #
  # Creates a new photo and associates it to the given pictureable. This view is loaded
  # inside an hidden IFRAME to implement the AJAX file upload (see the <tt>responds_to_parent</tt>
  # plugin).
  #
  #  * If the upload is not valid (ApplicationController#valid_file_upload?), nothing is
  #    rendered with a 400 status.
  #  * If the photo number exceeds the limit, the rendered javascript invokes the
  #    <tt>uploadLimitReached</tt> method of the <tt>GalleryUpload</tt> JS object
  #    defined in <tt>public/javascripts/user/gallery.js</tt>.
  #  * If the upload succeeds, an rjs view is invoked, that performs various tasks:
  #    inserts the photo partial on the page, updates Gallery and Lightview links
  #    and calls the uploadCompleted() JS method. (see <tt>views/photos/create.js.rjs</tt>)
  #  * If the photo model validation fails, the <tt>uploadFailed()</tt> method is called.
  #
  # The code is quite messy due to the oddities of the responds_to_parent plugin.
  #
  def create 
    unless valid_file_upload?(:photos)
      render :nothing => true, :status => :bad_request and return
    end

    respond_to do |format|
      if @upload_limit
        format.js do
          responds_to_parent do
            render(:update) { |page| page << %[GalleryUpload.instance.uploadLimitReached(#@upload_limit)] }
          end
        end
      else
        @photo = Photo.new(params[:photos])
        @photo.pictureable = @pictureable

        if @photo.save
          format.js do
            responds_to_parent { render }
          end
        else
          format.js do
            responds_to_parent do
              render(:update) { |page| page << %[GalleryUpload.instance.uploadFailed()] }
            end
          end
        end
      end
    end
  end

  # <tt>DELETE /users/:user_id/photos/:id</tt>
  # <tt>DELETE /mbands/:mband_id/photos/:id</tt>
  #
  # Removes a photo from the gallery and updates the page via a RJS view.
  # If the photo with the given id is not found, nothing is rendered with 
  # a 404 status. 
  #
  def destroy 
    @photo = @pictureable.photos.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to_pictureable_path }
      format.js
    end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found
  end

private

  # Filter that finds a pictureable using params[:user_id] or params[:mband_id].
  # If none is found, the client is redirected to '/'.
  #
  def find_pictureable
    if params[:user_id]
      @pictureable = User.find_from_param(params[:user_id])
      @user = @pictureable
    elsif params[:mband_id]
      @pictureable = Mband.find_from_param(params[:mband_id])  
      @mband = @pictureable
    else
      redirect_to '/'
    end
  end  
  
  # Filter that checks whether the current user is allowed to modify the gallery. If
  # this is an user gallery, the current user must match; if this is an mband gallery,
  # the current user must be a member of the mband.
  #
  def check_current_user   
    if params[:user_id]
      redirect_to '/' and return unless (current_user == @user) || current_user.is_admin?
    elsif params[:mband_id]
      redirect_to '/' and return unless @mband.members.include?(current_user) || current_user.is_admin?
    end
  end

  # Filter that checks the photo count of an user. Current limit is 10 photos per user.
  #
  def check_photo_count
    if @pictureable.photos.count > 9
      @upload_limit = 10
    end
  end

  # Helper that redirects to the current pictureable path, using <tt>mband_path</tt> if
  # it is an M-band or <tt>user_path</tt> if not.
  #
  def redirect_to_pictureable_path
    redirect_to(params[:mband_id] ? mband_path(@pictureable) : user_path(@pictureable))
  end
  
end
