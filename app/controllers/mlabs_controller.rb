# Myousica Mlabs Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
#
# == Description
#
# This controller handles M-Labs, which are Playlist items on the site.
# User playlist is persisted across sessions, hence this model.
#
# Login is required to access these actions (+login_required+) and an user can see and edit only
# its own Playlist (+check_playlist_access+).
#
# For details on the JS client, see <tt>public/javascripts/playlist.js</tt>.
#
class MlabsController < ApplicationController

  layout nil

  before_filter :login_required
  before_filter :check_playlist_access

  # ==== GET /users/:user_id/playlist.js
  #
  # Returns an index of the user songs and tracks in the Playlist, in JSON format.
  # The HTML output is not used and sends out a redirect to '/'.
  #
  def index
    respond_to do |format|
      format.js { render :json => Mlab.items_for(current_user) }
      format.html { redirect_to '/' }
    end
  end

  # ==== POST /users/:user_id/playlist.js
  #
  # Creates a new Mlab instance, associated to the <tt>current_user</tt> and to the mixable
  # whose id is passed via the <tt>item_id</tt> parameter. A mixable can be either a +Song+
  # or a +Track+. An user can trigger an Mlab creation, that is, add an item to its Playlist
  # by clicking the cyan "ADD" buttons throughout the site.
  #
  # The only format supported is JS, used by the bottom Playlist control.
  #
  def create
    mixable = case params[:type]
      when 'track'
        Track.find(params[:item_id])
      when 'song'
        Song.find(params[:item_id])
    end

    head :forbidden and return unless mixable.accessible_by?(current_user)

    @mlab = current_user.mlabs.create!(:mixable => mixable)

    respond_to do |format|
      format.js { render :json => mixable.to_json }
      format.html { redirect_to '/' }
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found

  rescue ActiveRecord::RecordInvalid
    render :json => {:errors => @mlab.errors}, :status => :bad_request
  end

  # ==== DELETE /users/:user_id/mlabs/id.js
  #
  # Destroys an Mlab, when the user requests removal of an item from the Playlist, triggering
  # it by clicking the "Trash" button in the scroller. The multitrack currently does not 
  # implement the Playist handling, the XML format is in place when it will.
  #
  def destroy
    destroyed = current_user.mlabs.find(params[:id]).destroy

    respond_to do |format|
      format.js { head(destroyed ? :ok : :bad_request) }
      format.html { redirect_to '/' }
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

private

  # Filter that checks the passed user id matches the <tt>current_user</tt> id, and
  # sends out a 403 forbidden status otherwise.
  #
  def check_playlist_access
    head :forbidden and return unless current_user.id == User.from_param(params[:user_id])
  end

end
