class MlabsController < ApplicationController  
  
  layout false
  
  before_filter :login_required, :except => :new
  before_filter :check_user_identity

  def index
    @songs = Song.find(:all, :include => [:mlabs, :user], :conditions => ["mlabs.user_id = ?", params[:user_id]])
    @tracks = Track.find(:all, :include => :mlabs, :conditions => ["mlabs.user_id = ?", params[:user_id]])
    @items = @tracks + @songs
    @show_mlab_id = true
    respond_to do |format|            
      format.xml do
        headers["Content-Type"] = "text/xml;"
      end
      format.js { render :json => @items.to_json(:methods => :user, :include => :mlabs) }
    end
    
  end
  
  def new
    respond_to do |format|
      format.xml { render :text => "<response><authenticity_token>#{form_authenticity_token if protect_against_forgery?}</authenticity_token></response>" }
    end
  end
  
  def create
    @mixable = case params[:type] 
      when 'track'        
        Track.find_by_id(params[:item_id])
      when 'song'
        Song.find_by_id(params[:item_id])
    end
    @user = User.find(params[:user_id])    
    @mlab = Mlab.create(:user => @user, :mixable => @mixable)
    @mixable.mlab = @mlab if @mlab.valid?
    
    respond_to do |format|
      format.js
      format.xml
    end
    #TODO: gestire eccezione recordnotfound
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
