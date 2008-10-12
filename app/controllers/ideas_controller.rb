# Myousica Ideas Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
#
# This controller implements the logic for the <tt>/ideas</tt> section of the site.
# Its functions are the +index+ page, pagination for +newest+ and +coolest+ ideas,
# and navigation of ideas +by_instrument+.
#
class IdeasController < ApplicationController

  before_filter :redirect_unless_xhr, :only => [:newest, :coolest, :by_instrument]

  # <tt>GET /ideas</tt>
  #
  # Show the index page of the ideas section, featuring newest, coolest, top rated and most
  # engaging ideas. See Track#find_paginated_newest_ideas, +Track.find_paginated_coolest_ideas+,
  # +Track.find_paginated_top_rated_ideas+ and +Track.find_most_collaborated_ideas+ for details.
  #
  # It also shows a listing of the 6 instruments with most ideas, and a table of all instruments.
  #
  def index
    @newest = Track.find_paginated_newest_ideas             :page => 1, :per_page => 4
    @coolest = Track.find_paginated_coolest_ideas           :page => 1, :per_page => 4
    @top_rated = Track.find_paginated_top_rated_ideas       :page => 1, :per_page => 4
    @most_engaging  = Track.find_most_collaborated_ideas                :limit => 4
    @ideas_instruments = Instrument.find_by_ideas_count                 :limit => 6
    @instruments = Instrument.find(:all)
  end
  
  # <tt>XHR GET /ideas/newest?page=N</tt>
  #
  # Paginate and render newest ideas for the topmost page blocks. Called via XHR.
  #
  def newest
    @newest = Track.find_paginated_newest_ideas :page => params[:page], :per_page => 4
    render :partial => 'newest'
  end
  
  # <tt>XHR GET /ideas/coolest?page=N</tt>
  #
  # Paginate and render coolest ideas for the topmost page blocks. Called via XHR.
  #
  def coolest
    @coolest = Track.find_paginated_coolest_ideas :page => params[:page], :per_page => 4
    render :partial => 'coolest'
  end
  
  # <tt>XHR GET /ideas/by_instrument[?instrument_id=N]</tt>
  #
  # If the <tt>instrument_id</tt> parameter is passed, renders a table with ideas details
  # using the <tt>app/views/songs/_track.html.erb</tt> partial. If it is not given, it
  # renders a table with the 6 instruments with most ideas.
  #
  def by_instrument
    @instruments = Instrument.find(:all)

    if params[:instrument_id]
      @instrument = Instrument.find(params[:instrument_id])
      @ideas = @instrument.find_paginated_ideas(:page => params[:ipage], :per_page => 8)
      render :layout => false
    else
      @ideas_instruments = Instrument.find_by_ideas_count :limit => 6
      render :partial => 'ideas_table'
    end

  end

private
  
  # Filter to redirect to ideas_url if the request is not XHR
  #
  def redirect_unless_xhr
    redirect_to ideas_path unless request.xhr?
  end
  
end
