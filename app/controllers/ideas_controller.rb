class IdeasController < ApplicationController

  before_filter :redirect_unless_xhr, :only => [:newest, :coolest, :by_instrument]

  def index
    @newest = Track.find_paginated_newest_ideas             :page => 1, :per_page => 4
    @coolest = Track.find_paginated_coolest_ideas           :page => 1, :per_page => 4
    @top_rated = Track.find_paginated_top_rated_ideas       :page => 1, :per_page => 4
    @most_engaging  = Track.find_most_collaborated_ideas                :limit => 4
    @ideas_instruments = Instrument.find_by_ideas_count                 :limit => 6
    @instruments = Instrument.find(:all)
  end
  
  def newest
    @newest = Track.find_paginated_newest_ideas :page => params[:page], :per_page => 4
    render :partial => 'newest'
  end
  
  def coolest
    @coolest = Track.find_paginated_coolest_ideas :page => params[:page], :per_page => 4
    render :partial => 'coolest'
  end
  
  def by_instrument
    @instruments = Instrument.find(:all)

    if params[:instrument_id]
      @instrument = Instrument.find(params[:instrument_id])
      @ideas = @instrument.find_paginated_ideas(:page => params[:ipage], :per_page => 8)
      render :layout => false
    else
      @ideas_instruments = Instrument.find_by_ideas_count :limit => 4
      render :partial => 'ideas_table'
    end

  end

private
  
  def redirect_unless_xhr
    redirect_to ideas_url unless request.xhr?
  end
  
end
