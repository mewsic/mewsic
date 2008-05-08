class SearchController < ApplicationController

  def show
    #FIXME: i risultati sono random
    @show_siblings_count = true
    @songs  = Song.paginate(:page => params[:song_page], :per_page => 4)
    @tracks = Track.paginate(:page => params[:track_page], :per_page => 4)
    respond_to do |format|
      format.html
      format.xml
    end
  end
end
