class MlabsController < ApplicationController

  layout nil

  before_filter :login_required
  before_filter :check_user_identity

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

  def create
    mixable = case params[:type]
      when 'track'
        Track.find(params[:item_id])
      when 'song'
        Song.find(params[:item_id])
    end

    @mlab = Mlab.create(:user => current_user, :mixable => mixable)
    if @mlab.valid?
      @item = Mlab.find_my_list_item_for(current_user, params[:type], mixable.id)
    end

    respond_to do |format|
      format.xml
      format.js
    end

  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => :bad_request
  end

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

  end

private

  # TODO: esportare questo metodo in una libreria in modo tale da usarlo in altri controller  
  def check_user_identity
    redirect_to('/') and return unless current_user.id == User.from_param(params[:user_id])
  end

end
