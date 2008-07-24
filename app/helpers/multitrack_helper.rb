module MultitrackHelper
  def instruments_used_in(song)
    song.tracks.map { |t| t.instrument.description }.join(', ')
  end

  def session_key
    "_myousica_session_key=#{cookies['_myousica_session_key']}"
  end
end
