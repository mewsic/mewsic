class Numeric
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
