class BandsAndDeejaysController < ApplicationController

  def index
    @coolest = User.find_coolest_band_or_deejays(:limit => 9)
    # TODO: al momento find_best_myousicians tira fuori le canzoni per non avere persone senza canzoni
    @best_myousicians = User.find_best_myousicians( :limit  => 3)
    @prolific = User.find_prolific_band_or_deejays(:limit => 3)
    @friendliest = User.find_friendliest(:limit => 1)
    @most_bands = [] #User.find_most_banded :limit => 1
    @newest = User.find(:all, :conditions => ["type = ? OR type = ?", 'Band', 'Dj'], :limit => 3, :order => 'created_at DESC')
    @most_instruments = User.find_band_or_deejay_with_more_instruments
  end

  def to_breadcrumb
    'bands &amp; deejays'
  end
end
