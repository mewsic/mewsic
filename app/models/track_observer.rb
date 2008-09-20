class TrackObserver < ActiveRecord::Observer
  def after_create(track)
    MyousicaMailer.deliver_new_track_notification(track)
  end
end
