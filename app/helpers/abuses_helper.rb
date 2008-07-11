module AbusesHelper
  def abuseable_url(abuseable)
    send("#{abuseable.class.name.downcase}_url", abuseable)
  end
end
