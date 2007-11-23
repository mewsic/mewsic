class MusicController < ApplicationController
  def index
    @best_songs = Song.find_best :limit => 3, :include => [:tracks, :user]
    @most_used_tracks = Track.find_most_used :limit => 3
  end
end
