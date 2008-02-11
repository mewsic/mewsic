class MusicController < ApplicationController
  def index
    @best_songs = Song.find_best :limit => 3, :include => [:tracks, :user]
    @most_used_tracks = Track.find_most_used :limit => 3
    @genres = Genre.find_paginated(1)
    @newest_songs = Song.find_newest :limit => 3, :include => [:tracks, :user]
    @newest_answers = Answer.find_newest :limit => 3, :include => [:user, :replies]
  end
end
