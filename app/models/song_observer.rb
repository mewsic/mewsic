class SongObserver < ActiveRecord::Observer
  def after_save(song)
    # These actions are performed only if the song has just been published
    return unless song.new?

    # Deliver administrative notification
    MyousicaMailer.deliver_new_song_notification(song)

    # Build an hash with users as keys and used tracks as values
    collaborations = song.tracks.inject({}) do |h, track|
      if track.user != song.user
        h[track.user] ||= []
        h[track.user] << track
      end
      h
    end

    # Deliver collaboration notification to all the participants of the song
    collaborations.each do |user, tracks|
      MyousicaMailer.deliver_collaboration_notification(user, song, tracks)
    end

  end
end
