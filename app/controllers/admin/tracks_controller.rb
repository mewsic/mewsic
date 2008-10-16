require 'multipart'

class Admin::TracksController < Admin::AdminController #:nodoc:
  def index
    @tracks = Track.find(:all, :order => 'title', :order => 'id DESC')
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
    update_after_destroy
  end

  def upload
    url = URI.parse "#{APPLICATION[:media_url]}/upload"
    if params[:Filedata] && params[:Filedata].respond_to?(:size) && params[:Filedata].size > 0
      query, headers = Multipart::Post.prepare_query(:Filedata => params[:Filedata])
      res = Net::HTTP.start(url.host, url.port) { |http| http.post(url.path, query, headers) }
    elsif params[:worker]
      url = URI.parse("#{APPLICATION[:media_url]}/upload/status/#{params[:worker]}")
      res = Net::HTTP.start(url.host, url.port) { |http| http.get(url.path) }
    else
      render :text => 'invalid request', :status => :bad_request and return
    end

    render :text => res.body, :status => :bad_request and return unless res.is_a?(Net::HTTPSuccess)

    responds_to_parent do
      render :update do |page|
        page << %[TrackUpload.instance.responder('#{escape_javascript(res.body)}')]
      end
    end
  end
end
