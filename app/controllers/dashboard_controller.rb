class DashboardController < ApplicationController
  
  before_filter :redirect_unless_xhr, :only => [:splash, :top]
  before_filter :find_splash_songs, :except => :noop
  session :off, :only => :noop
  
  def index
    #@bands = User.find :all, :limit => 3, :include => [:avatars, :songs], :conditions => ["(users.type = 'Band' OR users.type = 'Dj') AND users.activated_at IS NOT NULL AND pictures.id IS NOT NULL AND songs.published = ? AND songs.id IS NOT NULL", true], :order => SQL_RANDOM_FUNCTION
    #@answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [{:user => :avatars}], :conditions => ["users.activated_at IS NOT NULL"]
    #@songs = Song.find :all, :limit => 3, :include => [{:user => :avatars}], :conditions => ['songs.published = ?', true], :order => SQL_RANDOM_FUNCTION
    #@ideas = Track.find :all, :limit => 2, :include => {:owner => :avatars}, :conditions => ['tracks.idea = ?', true], :order => SQL_RANDOM_FUNCTION

    @people = find_top_myousicians :limit => 6

    @motto = Motto.find :random
  end

  def splash
    @motto = Motto.find :random
    render :partial => 'splash'
  end

  def top
    @people = find_top_myousicians(:limit => 10).sort_by{rand}.slice(0, 6).sort{|a,b|b.tracks_count.to_i <=> a.tracks_count.to_i}
    render :partial => 'myousician', :collection => @people
  end

  def noop
    if params[:id]
      render :text => params[:id].to_i
    else
      head :ok
    end
  end

private 

  def redirect_unless_xhr
    redirect_to '/' and return unless request.xhr?
  end

  def find_splash_songs    
    @random_siblings = Song.find_random_direct_siblings(1)
    if @random_siblings.size > 0
      @splash_song = @random_siblings[0].song
      @splash_songs = @splash_song.direct_siblings(3).unshift(@splash_song)
      @splash_tracks = @splash_song.tracks.find(:all, :limit => 4)
    else
      @splash_songs, @splash_tracks = [], []
    end    
  end
  
  def find_top_myousicians(options = {})
    User.find :all, options.merge(
      :select => 'COUNT(tracks.id) AS tracks_count, users.*',
      :joins => 'INNER JOIN tracks ON tracks.user_id = users.id',
      :conditions => ["users.activated_at IS NOT NULL "], #XXX XXX AND pictures.id IS NOT NULL XXX XXX
      :order => 'tracks_count DESC, users.rating_avg DESC',
      :group => 'users.id')
  end
  
end
