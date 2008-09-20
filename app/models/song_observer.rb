class SongObserver < ActiveRecord::Observer
  def after_save(song)
    MyousicaMailer.deliver_new_song_notification(song) if song.new?
  end
end
