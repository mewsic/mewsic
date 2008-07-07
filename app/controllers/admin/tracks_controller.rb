class Admin::TracksController < Admin::AdminController
  def index
    @tracks = Track.find(:all, :order => 'title', :order => 'id')
  end

  def new
    @track = Track.new
    render :action => 'show'
  end

  def show
    @track = Track.find(params[:id])
  end

  def create
    @track = Track.new(params[:track])
    @track.save!

    Mix.create! :song_id => @track.song_id, :track_id => @track.id

    @track = Track.new :song_id => @track.song_id

  rescue ActiveRecord::ActiveRecordError
  ensure
    render :action => 'show'
  end

  def update
    @track = Track.find(params[:id])
    @track.update_attributes! params[:track]
    render(:update) { |page| page.hide 'editing' }

  rescue ActiveRecord::ActiveRecordError
    render :action => 'show'
  end

  def destroy
    Track.find(params[:id]).destroy
    render(:update) { |page| page.hide 'editing' }
  end
end
