class MlabsController < ApplicationController 
  
  #protect_from_forgery :except => [:destroy, :create]
  
  layout false
  
  before_filter :login_required
  before_filter :check_user_identity

  def index
    @songs = Song.find(:all, :include => [:mlabs, :user], :conditions => ["mlabs.user_id = ?", params[:user_id]])
    @tracks = Track.find(:all, :include => :mlabs, :conditions => ["mlabs.user_id = ?", params[:user_id]])    
    @items = @tracks + @songs
    respond_to do |format|
      format.js { render :json => @items.to_json(:methods => :user, :include => :mlabs) }
      format.xml      
    end
    
  end
  
  def create
    @mixable = case params[:type] 
      when 'track'        
        Track.find_by_id(params[:item_id])
      when 'song'
        Song.find_by_id(params[:item_id])
    end    
    @mlab = Mlab.create(:user => current_user, :mixable => @mixable)
    @mixable.mlab = @mlab if @mlab.valid?
    
    respond_to do |format|
      format.js
      format.xml
    end
  end    
  
  def destroy
    @mlab     = Mlab.find(params[:id])
    @mixable  = @mlab.mixable
    @mlab.destroy      
  end

private

  # TODO: esportare questo metodo in una libreria in modo tale da usarlo in altri controller  
  def check_user_identity
    redirect_to('/') and return unless current_user.id == params[:user_id].to_i
  end

end
