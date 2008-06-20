class DashboardController < ApplicationController
  
  before_filter :find_splash_songs
  
  def index
    @people = User.find :all, :limit => 6, :include => [:avatars, :songs], :conditions => ["users.type = 'User' AND users.activated_at IS NOT NULL AND pictures.id IS NOT NULL"], :order => SQL_RANDOM_FUNCTION
    @answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [{:user => :avatars}], :conditions => ["users.activated_at IS NOT NULL"]
    # TODO: Qui dovrei trovare degli utenti e non delle canzoni, ma così evitiamo di avere utenti con canzoni vuote
    @songs = Song.find :all, :limit => 3, :include => [{:user => [:avatars, :songs]}], :conditions => ['songs.published = ?', true], :order => SQL_RANDOM_FUNCTION
    @ideas = Track.find_orphans(:limit => 2)
  end
  
  def splash
    redirect_to '/' and return unless request.xhr?
    render :partial => 'splash'
  end

private 

  def find_splash_songs    
    @random_siblings = Song.find_random_direct_siblings(1)
    if @random_siblings.size > 0
      @splash_song = @random_siblings[0].song
      @splash_songs = @splash_song.direct_siblings(3).collect{|mix| mix.song}.unshift(@splash_song)
      @splash_tracks = @splash_song.tracks.find(:all, :limit => 4)
    else
      @splash_songs, @splash_tracks = [], []
    end    
  end
  
end
