class Admin::SongsController < Admin::AdminController
  def index
    @songs = Song.find(:all, :conditions => ['published = ?', true], :order => 'id')
  end
  
  def show
    @song = Song.find(params[:id])
  end

  def update
    @song = Song.find(params[:id])
    @song.update_attributes! params[:song]
    render :action => 'show'
  end
end
