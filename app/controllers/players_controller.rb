class PlayersController < ApplicationController
  
  layout false
  
  before_filter :redirect_to_root_unless_xhr
  before_filter :find_playable

  def show
    @playable.increment_listened_times    
    @waveform = send("formatted_#{@playable.class.name.underscore}_path", @playable, 'png')
  end
  
private
  
  def find_playable
    @playable = if params[:track_id]
      Track.find(params[:track_id])
    elsif params[:song_id]
      Song.find(params[:song_id])
    else
      redirect_to '/' and return
    end
  end

end
