# Myousica Bands and Deejays Controller
#
# (C) 2008 Medlar s.r.l.
# 
# The bands & deejays page controller. It merely displays an index page similar to the users
# one. Every other user operation is handled via the UsersController.
#
class BandsAndDeejaysController < ApplicationController

  # <tt>GET /bands_and_deejays</tt>
  #
  # Shows the index page for bands and deejays, with coolest, best myousicians,
  # prolific users, most admired, coolest mbands, newest bands/deejays and most
  # instrument ones.
  #
  def index
    @coolest = User.find_coolest_band_or_deejays           :limit => 9
    @best_myousicians = User.find_best_band_or_deejays     :limit => 3
    @prolific = User.find_prolific_band_or_deejays         :limit => 3
    @most_admired = User.find_most_admired_band_or_deejays :limit => 1
    @coolest_mbands = Mband.find_coolest                   :limit => 1
    @newest = User.find_newest_band_or_deejays             :limit => 3
    @most_instruments = User.find_most_instruments_band_or_deejays :limit => 1
  end

  # Helper to show in the breadcrumb a descriptive title of this section
  #
  def to_breadcrumb
    'Bands &amp; deejays'
  end
end
