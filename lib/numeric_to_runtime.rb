class Numeric
  # Helper that transforms an integer length in seconds to a String formatted
  # as standard HH:MM:SS (or MM:SS if the stream lasts less than one hour).
  #
  def to_runtime
    hours, remainder = divmod(3600)
    minutes, seconds = remainder.divmod(60)
    if hours > 0
      "%02d:%02d:%02d" % [hours, minutes, seconds]
    else
      "%02d:%02d" % [minutes, seconds]
    end
  end
end
