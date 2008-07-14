require 'net/http'
require 'uri'

class Admin::SongsController < Admin::AdminController
  def index
    @songs = Song.find(:all, :conditions => 'title is not null', :order => 'id DESC')
  end

  def new
    @song = Song.new
    render :action => 'show'
  end
  
  def show
    @song = Song.find(params[:id])
  end

  def create
    @song = Song.new(params[:song])
    @song.save!

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

  def mix
    Mix.create! :song_id => params[:id], :track_id => params[:track_id]
    @song = Song.find(params[:id])
    render :action => 'show'
  end

  def unmix
    Mix.find_by_track_id_and_song_id(params[:track_id], params[:id]).destroy
    @song = Song.find(params[:id])
    render :action => 'show'
  end

  def mp3
    if params[:song]
      url = URI.parse("#{APPLICATION[:media_url]}/mix")
      res = Net::HTTP.post_form(url, {'song' => params[:song]})
    elsif params[:worker]
      url = URI.parse("#{APPLICATION[:media_url]}/mix/status/#{params[:worker]}")
      res = Net::HTTP.start(url.host, url.port) { |http| http.get(url.path) }
    else
      render :text => 'invalid request', :status => :bad_request and return
    end

    render :text => res.body, :status => :bad_request and return unless res.is_a?(Net::HTTPSuccess)

    respond_to do |format|
      format.xml { render :text => res.body }
    end
  end

end
