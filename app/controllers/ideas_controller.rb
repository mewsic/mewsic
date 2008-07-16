class IdeasController < ApplicationController

  before_filter :redirect_unless_xhr, :only => [:newest, :coolest, :by_instrument]

  def index
    @newest = Track.find_paginated_newest_ideas(1)
    @coolest = Track.find_paginated_coolest_ideas(1)
    @top_rated = Track.find_paginated_top_rated_ideas(1)
    @most_engaging  = Track.find_most_collaborated(3)
    @ideas_instruments = Instrument.find_by_ideas_count
    @instruments = Instrument.find(:all)
  end
  
  def newest
    @newest = Track.find_paginated_newest_ideas params[:page]
    render :partial => 'newest'
  end
  
  def coolest
    @coolest = Track.find_paginated_coolest_ideas params[:page]
    render :partial => 'coolest'
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
  
end
