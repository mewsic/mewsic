class IdeasController < ApplicationController

  before_filter :redirect_unless_xhr, :only => [:newest, :coolest, :by_instrument]

  def index
    @newest   = find_newest
    @coolest  = find_coolest
    @top_rated  = Track.find(:all, :conditions => ['idea = ?', true], :limit => 3, :order => 'tracks.rating_avg DESC')
    @most_engaging  = Track.find_most_collaborated(3)
    @ideas_instruments = Instrument.find_by_ideas_count
    @instruments = Instrument.find(:all)
  end
  
  def newest
    @newest = find_newest
    render :layout => false
  end
  
  def coolest
    @coolest = find_coolest
    render :layout => false
  end
  
  def by_instrument
    @instrument = Instrument.find(params[:instrument_id])
    @ideas = @instrument.ideas.paginate(:per_page => 10, :page => params[:ipage])
    render :layout => false
  end

private
  
  def redirect_unless_xhr
    redirect_to ideas_url unless request.xhr?
  end
  
  def find_newest
    Track.paginate(:per_page => 3, :page => params[:npage], :conditions => ["tracks.idea = ?", true], :limit => 3, :order => "tracks.created_at DESC")
  end

  def find_coolest
    Track.paginate(:per_page => 3, :page => params[:cpage], :conditions => ["tracks.idea = ?", true], :limit => 3, :order => "tracks.created_at DESC")
  end
  
end
