class SearchController < ApplicationController

  def show
    #FIXME: i risultati sono random
    @show_siblings_count = true
    @users = User.paginate(:per_page => 6, :page => params[:page], :conditions => ["users.login LIKE ?", "%#{params[:id]}%"])
    @songs  = Song.paginate(:page => params[:song_page], :per_page => 4)
    @tracks = Track.paginate(:page => params[:track_page], :per_page => 4)
    respond_to do |format|
      format.html do
        if params[:type]
          case params[:type]
            when 'people'
              render(:partial => 'people_results', :layout => false) and return
          end
        end
      end
      format.xml
    end
  end
end
