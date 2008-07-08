class IdeasController < ApplicationController

  def index
    @newest   = Track.find(:all, :conditions => ["tracks.idea = ?", true], :limit => 3, :order => "tracks.created_at DESC")
    @coolest  = Track.find(:all, :conditions => ["tracks.idea = ?", true], :limit => 3, :order => "tracks.created_at DESC")
    @top_rated  = Track.find(:all) #, :conditions => '1', :limit => 3)
    @most_engaging  = Track.find_most_collaborated(3)
    @ideas_instruments = Instrument.find_by_ideas_count
    @instruments = Instrument.find(:all)
  end
end
