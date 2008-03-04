class SearchController < ApplicationController

  def show
    #FIXME: i risultati sono random
    @songs  = Song.paginate(:page => params[:song_page], :per_page => 10)
    @tracks = Track.paginate(:page => params[:track_page], :per_page => 10)
    respond_to do |format|
      format.xml
    end
  end
end
