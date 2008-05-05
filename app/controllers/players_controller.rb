class PlayersController < ApplicationController
  
  layout false
  
  before_filter :find_playable

  def show
    @playable.increment_listened_times    
  end
  
private
  
  def find_playable
    @playable = if params[:track_id]
      Track.find(params[:track_id])
    else
      Song.find(params[:song_id])
    end
  end

end
