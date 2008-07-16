module MultitrackHelper
  def instruments_used_in(song)
    song.tracks.map { |t| t.instrument.description }.join(', ')
  end
end
