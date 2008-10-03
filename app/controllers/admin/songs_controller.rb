require 'net/http'
require 'uri'
require 'requestify'

class Admin::SongsController < Admin::AdminController
  include Requestify

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
    @song = Song.create(params[:song])
    if @song.valid?
      @track = Track.new :song_id => @song.id
      render :template => 'admin/tracks/show'
    else
      render :action => 'show'
    end
  end

  def update
    @song = Song.find(params[:id])
    if @song.update_attributes params[:song]
      render(:update) { |page| page.hide 'editing' }
    else
      render :action => 'show'
    end
  end

  def destroy
    Song.find(params[:id]).destroy
    update_after_destroy
  end

  def mix
    @song = Song.find(params[:id])
    mix = Mix.create :song_id => @song.id, :track_id => params[:track_id]
    flash.now[:error] = mix.errors.to_a.join(' ') unless mix.valid?

    render :action => 'show'
  end

  def unmix
    Mix.find_by_track_id_and_song_id(params[:track_id], params[:id]).destroy
    @song = Song.find(params[:id])
    render :action => 'show'
  end

  def mp3
    current_user.enter_multitrack!
    token = "?id=#{current_user.id}&token=#{current_user.multitrack_token}"
    if params[:tracks]
      url = URI.parse("#{APPLICATION[:media_url]}/mix")
      res = Net::HTTP.start(url.host, url.port) { |http| http.post(url.path + token, requestify(:tracks => params[:tracks])) }
    elsif params[:worker]
      url = URI.parse("#{APPLICATION[:media_url]}/mix/status/#{params[:worker]}")
      res = Net::HTTP.start(url.host, url.port) { |http| http.get(url.path + token) }
    else
      render :text => 'invalid request', :status => :bad_request and return
    end

    render :text => res.body, :status => :bad_request and return unless res.is_a?(Net::HTTPSuccess)

    respond_to do |format|
      format.xml { render :text => res.body }
    end
  end

end
