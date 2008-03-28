class DashboardController < ApplicationController
  
  def index
    @people = User.find :random, :limit => 6, :include => [:avatars, :songs], :conditions => ["activated_at IS NOT NULL"]
    @answers = Answer.find :all, :order => 'answers.created_at DESC', :limit => 2, :include => [:replies, {:user => :avatars}], :conditions => ["users.activated_at IS NOT NULL"]
    # TODO: Qui dovrei trovare degli utenti e non delle canzoni, ma così evitiamo di avere utenti con canzoni vuote
    @songs = Song.find :random, :limit => 2, :include => [{:user => [:avatars, :songs]}]
  end
  
  def mylist
    # TODO: qui dobbiamo prendere le song nella mylist, 100 a caso.
    @songs = Song.find :all, :limit => 100
  end
end