class PlayersController < ApplicationController
  
  before_filter :find_playable
  layout false

  def show
    redirect_to '/' and return unless @playable #&& request.xhr?

    session[:playcount_barrier] = Time.now.to_i + @playable.seconds/2
    @playable_type = @playable.class.name.underscore
    @playcount_path = send("#{@playable_type}_increment_path", @playable)
    @waveform = send("formatted_#{@playable_type}_path", @playable, 'png')
  end

  def increment
    if session[:playcount_barrier].nil? || Time.now.to_i < session[:playcount_barrier]
      head :bad_request
    else
      @playable.increment_listened_times
      head :ok
    end
    session[:playcount_barrier] = nil
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
