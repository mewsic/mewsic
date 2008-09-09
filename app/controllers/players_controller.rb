class PlayersController < ApplicationController
  
  layout false
  
  before_filter :find_playable

  def show
    redirect_to '/' and return unless @playable && request.xhr?

    @playable.increment_listened_times    
    @stream = @playable.public_filename
    @length = @playable.seconds
    @image = send("formatted_#{@playable.class.name.underscore}_path", @playable, 'png')
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
