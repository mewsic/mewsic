class Genre < ActiveRecord::Base
  has_many :tracks
  
  def self.find_paginated(page)
    paginate :per_page => 5, :order => "name ASC", :include => :tracks, :page => page
  end
end
