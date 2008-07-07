class Admin::SongsController < Admin::AdminController
  def index
    @songs = Song.find(:all, :conditions => ['published = ?', true], :order => 'id')
  end

  def new
    @song = Song.new
    render :action => 'show'
  end
  
  def show
    @song = Song.find(params[:id])
  end

  def create
    @song = Song.create!(params[:song])
    @track = Track.new :song_id => @song.id
    render :template => 'admin/tracks/show'

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end

  def update
    @song = Song.find(params[:id])
    @song.update_attributes! params[:song]
    render(:update) { |page| page.hide 'editing' }

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end

  def destroy
    Song.find(params[:id]).destroy
    render(:update) { |page| page.hide 'editing' }
  end
end
