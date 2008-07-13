class MusicController < ApplicationController
  def index
    @best_songs = Song.find_best :limit => 3, :include => [:tracks, :user]
    @most_used_tracks = Track.find_most_used :limit => 3
    @genre_chars = Genre.find_with_songs(:all).map { |g| g.name.first.upcase }.uniq.sort
    @genres = Genre.find_with_songs(:all, :conditions => ["name LIKE ?", "#{@genre_chars.first}%"])
    @newest_songs = Song.find_newest :limit => 5, :include => [:tracks, :user]
    @newest_answers = Answer.find_newest :limit => 3, :include => [:user, :replies]
  end

  def top
    unless %w(song track).include? params[:type]
      render :nothing => true, :status => :bad_request and return
    end

    model, method, partial, options = {
      'song'  => [Song,  :find_best, 'best_song', {:include => [:tracks, :user]}],
      'track' => [Track, :find_most_used, 'most_used_track', {}]
    }.fetch(params[:type])

    collection = model.send(method, options.merge(:limit => 15)).sort_by{rand}[0..2]
    collection = collection.sort {|b,a| (a.rating_avg || 0) <=> (b.rating_avg || 0)}

    render :partial => partial, :collection => collection
  end
end
