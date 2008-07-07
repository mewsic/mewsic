class Admin::TracksController < Admin::AdminController
  def index
    @tracks = Track.find(:all, :order => 'title', :order => 'id')
  end

  def show
    @track = Track.find(params[:id])
  end

  def update
    @track = Track.find(params[:id])
    @track.update_attributes! params[:track]
    render :action => 'show'
  end
end
