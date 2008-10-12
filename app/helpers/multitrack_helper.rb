module MultitrackHelper
  def instruments_used_in(song)
    song.tracks.map { |t| t.instrument.description }.join(', ')
  end

  def multitrack_auth_token
    if logged_in?
      h("id=#{current_user.id}&token=#{current_user.multitrack_token}")
    end
  end

  def not_logged_in_notice
    flash.now[:notice] = %(You are not logged in. Saving will be disabled, please <a href="/login">log in</a> or <a href="/signup">sign up</a> if you want to save your work!)
  end
end
