class DashboardController < ApplicationController
  
  before_filter :find_splash_songs
  
  def index
    @people = User.find :random, :limit => 6, :include => [:avatars, :songs], :conditions => ["activated_at IS NOT NULL"]
    @answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [{:user => :avatars}], :conditions => ["users.activated_at IS NOT NULL"]
    # TODO: Qui dovrei trovare degli utenti e non delle canzoni, ma così evitiamo di avere utenti con canzoni vuote
    @songs = Song.find :random, :limit => 3, :include => [{:user => [:avatars, :songs]}], :conditions => ['published = ?', true]
    @ideas = Track.find_orphans(:limit => 2)
  end
  

private 

  def find_splash_songs
    @splash_tracks  = Track.find(:all, :limit => 4)   
    @splash_songs   = Song.find(:all, :limit => 4)   
  end
  
end
