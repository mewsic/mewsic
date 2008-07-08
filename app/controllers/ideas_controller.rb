class IdeasController < ApplicationController

  def index
    @newest   = Track.find(:all, :conditions => ["tracks.idea = ?", true], :limit => 3, :order => "tracks.created_at DESC")
    @coolest  = Track.find(:all, :conditions => ["tracks.idea = ?", true], :limit => 3, :order => "tracks.created_at DESC")
    @top_rated  = Song.find(:all, :limit => 3)
    @most_engaging  = Song.find(:all, :limit => 3)
    @ideas_instruments = Instrument.find_by_ideas_count
    @instruments = Instrument.find(:all)
  end
end
