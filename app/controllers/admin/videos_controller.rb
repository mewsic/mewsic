class Admin::VideosController < Admin::AdminController
  def index
    @videos = Video.find(:all, :order => 'position')
  end

  def rearrange
    @page = Video.find(params[:id])
    @page.send!(params[:move] == 'up' ? :move_higher : :move_lower)
    
    index
    render :action => 'index'
  end
  
  def show
    @video = Video.find(params[:id])
  end

  def update
    @video = Video.find(params[:id])
    if @video.update_attributes! params[:video]
      render(:update) { |page| page.hide 'editing' }
    else
      render :action => 'show'
    end
  end
end
