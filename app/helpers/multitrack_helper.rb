module MultitrackHelper
  def instruments_used_in(song)
    song.tracks.map { |t| t.instrument.description }.join(', ')
  end

  def multitrack_auth_token
    if logged_in?
      h("id=#{current_user.id}&token=#{current_user.multitrack_token}")
    end
  end

  def instrument_image_path(instrument)
    image_path File.join('instruments', 'blue_big', instrument.icon)
  end
end
