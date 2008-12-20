# Myousica Bands and Deejays Controller
#
# Copyright:: (C) 2008 Medlar s.r.l.
# 
# The bands & deejays page controller. It merely displays an index page similar to the users
# one. Every other user operation is handled via the UsersController.
#
class BandsAndDeejaysController < ApplicationController

  before_filter :redirect_unless_xhr, :only => [:newest, :coolest, :prolific]

  # ==== GET /bands_and_deejays
  #
  # Shows the index page for bands and deejays, with coolest, best myousicians,
  # prolific users, most admired, coolest mbands, newest bands/deejays and most
  # instrument ones.
  #
  def index
    @coolest = User.find_paginated_coolest_bands_and_deejays        :limit => 9
    @best = User.find_paginated_best_bands_and_deejays  :page => 1, :per_page => 3
    @prolific = User.find_paginated_prolific_bands_and_deejays      :page => 1, :per_page => 3
    @most_admired = User.find_most_admired_band_or_deejays          :limit => 1
    @coolest_mbands = Mband.find_coolest                            :limit => 1
    @newest = User.find_paginated_newest_bands_and_deejays          :page => 1, :per_page => 3
    @most_instruments = User.find_most_instruments_band_or_deejays  :limit => 1
  end
  
  # ==== XHR GET /bands_and_deejays/newest?page=N
  #
  # Paginate and render newest bands and djs for the topmost page blocks. Called via XHR.
  #
  def newest
    @newest = User.find_paginated_newest_bands_and_deejays :page => params[:page], :per_page => 3
    render :partial => 'newest'
  end
  
  # ==== XHR GET /bands_and_deejays/coolest?page=N
  #
  # Paginate and render coolest bands and djs for the topmost page blocks. Called via XHR.
  def coolest
    @coolest = User.find_paginated_coolest_bands_and_deejays :page => params[:page], :per_page => 9
    render :partial => 'coolest'
  end

  # ==== XHR GET /bands_and_deejays/prolific?page=N
  #
  # Paginate and render most prolific bands and djs for the topmost page blocks. Called via XHR.
  def prolific
    @prolific = User.find_paginated_prolific_bands_and_deejays :page => params[:page], :per_page => 3
    render :partial => 'prolific'
  end  
  
  # ==== XHR GET /bands_and_deejays/best?page=N
  #
  # Paginate and render most prolific bands and djs for the topmost page blocks. Called via XHR.
  def best
    @best = User.find_paginated_best_bands_and_deejays :page => params[:page], :per_page => 3
    render :partial => 'best'
  end

  # Helper to show in the breadcrumb a descriptive title of this section
  #
  def to_breadcrumb_link
    ['Bands &amp; deejays', nil]
  end
  
private

  # Filter to redirect to bands_and_deejays_url if the request is not XHR
  #
  def redirect_unless_xhr
    redirect_to bands_and_deejays_path unless request.xhr?
  end
    
end
