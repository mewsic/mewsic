class BandsAndDeejaysController < ApplicationController

  def index
    @coolest = User.find_coolest_band_or_deejays         :limit => 9
    @best_myousicians = User.find_best_band_or_deejays   :limit => 3
    @prolific = User.find_prolific_band_or_deejays       :limit => 3
    @friendliest = User.find_friendliest_band_or_deejays :limit => 1
    @newest = User.find_newest_band_or_deejays           :limit => 3
    @most_instruments = User.find_most_instruments_band_or_deejays :limit => 1
  end

  def to_breadcrumb
    'bands &amp; deejays'
  end
end
