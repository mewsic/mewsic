class MlabsController < ApplicationController 
  
  protect_from_forgery :except => [:destroy, :create]
  
  layout false
  
  before_filter :login_required
  before_filter :check_user_identity

  def index
    @songs = Song.find(:all, :include => [:mlabs, :user], :conditions => ["mlabs.user_id = ?", params[:user_id]])
    @tracks = Track.find(:all, :include => :mlabs, :conditions => ["mlabs.user_id = ?", params[:user_id]])    
    @songs = @songs.collect do |s|
      attributes = s.attributes
      attributes[:author] = {:login => s.user.login, :id => s.user.id}
      attributes[:mlab_id] = s.mlabs.first.id
      attributes
    end    
    @tracks = @tracks.collect do |t|
      attributes = t.attributes
      attributes[:author] = {:login => t.parent_song.user.login, :id => t.parent_song.user.id}
      attributes[:mlab_id] = t.mlabs.first.id
      attributes
    end
    @items = @tracks + @songs
    respond_to do |format|
      format.js { render :json => @items }
    end
    
  end
  
  def create
    @mixable, @mixable_attributes = case params[:type] 
      when 'track'        
        track = Track.find(params[:track_id])
        attributes = track.attributes
        attributes[:author] = {:login => track.parent_song.user.login, :id => track.parent_song.user.id}
        [track, attributes]
      when 'song'
        song = Song.find(params[:song_id])
        attributes = song.attributes
        attributes[:author] = {:login => song.user.login, :id => song.user.id}        
        [song, attributes]
    end    
    @mlab = Mlab.create(:user => current_user, :mixable => @mixable)
    @mixable_attributes[:mlab_id] = @mlab.id
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
