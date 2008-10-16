# Myousica Mlabs Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
#
# == Description
#
# This controller handles M-Labs, which are the rows shown in the "My List" scroller on the right
# sidebar of the site. Because the My List is stateful, its contents are saved to the database in
# order to make them fetchable by different sources (the scroller and the multitrack, as of now).
#
# Because of the high number of requests this controller receives, the data fetch is optimized in
# the model (see Mlab#find_my_list_items_for and Mlab#find_my_list_item_for). Login is required to
# access these actions (+login_required+) and an user can see only its own My List
# (+check_user_identity+).
#
# For details on the JS client, see <tt>public/javascripts/mlab.js</tt>. The XML client is written
# in AS3 and resides under the <tt>myousica-multitrack-editor</tt> github repository.
#
class MlabsController < ApplicationController

  layout nil

  before_filter :login_required
  before_filter :check_user_identity

  # ==== GET /users/:user_id/mlabs.xml
  # ==== GET /users/:user_id/mlabs.js
  #
  # Returns an index of the user songs and tracks in the My List basket. The XML format uses two
  # eager-loaded queries, results are printed out using the <tt>app/views/shared/_{song,track}.xml.erb</tt>
  # views.
  #
  # The JS output is optimized because it does receive a request on every page load, so the
  # Mlab#find_my_list_items_for method is called.
  #
  # The HTML output is not used and sends out a redirect to '/'.
  #
  def index
    respond_to do |format|
      format.xml do
        @songs = Song.find(:all, :include => [:mlabs, :user], :conditions => ["mlabs.user_id = ?", current_user])
        @tracks = Track.find(:all, :include => [:mlabs, :owner], :conditions => ["mlabs.user_id = ?", current_user])
      end

      format.js do
        render :json => Mlab.find_my_list_items_for(current_user)
      end

      format.html { redirect_to '/' }
    end
  end

  # ==== POST /users/:user_id/mlabs.js
  # ==== POST /users/:user_id/mlabs.xml
  #
  # Creates a new Mlab instance, associated to the <tt>current_user</tt> and to the mixable
  # whose id is passed via the <tt>item_id</tt> parameter. A mixable can be either a +Song+
  # or a +Track+. An user can trigger an Mlab creation, that is, add an item to the My List
  # by clicking the cyan "M" buttons throughout the site.
  #
  # The XML format will be used by the multitrack, when it will implement My List addition,
  # the JS format is instead used by the right sidebar My List scroller.
  #
  def create
    mixable = case params[:type]
      when 'track'
        Track.find(params[:item_id])
      when 'song'
        Song.find(params[:item_id])
    end

    @mlab = Mlab.new(:user => current_user, :mixable => mixable)
    @mlab.save!

    @item = Mlab.find_my_list_item_for(current_user, params[:type], mixable.id)

    respond_to do |format|
      format.xml { render :nothing => true, :status => :ok }
      format.js
    end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found

  rescue ActiveRecord::RecordInvalid
    render :partial => 'shared/errors', :object => @mlab.errors, :status => :bad_request
  end

  # ==== DELETE /users/:user_id/mlabs/id.js
  # ==== DELETE /users/:user_id/mlabs/id.xml
  #
  # Destroys an Mlab, when the user requests removal of an item from the My List, triggering
  # it by clicking the "Trash" button in the scroller. The multitrack currently does not 
  # implement the My List handling, the XML format is in place when it will.
  #
  def destroy
    @mlab     = Mlab.find(params[:id])
    @mixable  = @mlab.mixable

    if @mlab.destroy
      respond_to do |format|
        format.xml { render :nothing => true, :status => :ok }
        format.js  { render :nothing => true, :status => :ok }
      end
    else
      respond_to do |format|
        format.xml { render :nothing => true, :status => :bad_request }
        format.js  { render :nothing => true, :status => :bad_request }
      end
    end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :not_found

  end

private

  # Filter that checks the passed user id matches the <tt>current_user</tt> id.
  # TODO: export this method in a library in order to be used from other controllers
  #
  def check_user_identity
    redirect_to('/') and return unless current_user.id == User.from_param(params[:user_id])
  end

end
