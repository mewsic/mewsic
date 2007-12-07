# == Schema Information
# Schema version: 9
#
# Table name: genres
#
#  id   :integer(11)   not null, primary key
#  name :string(255)   
#

class Genre < ActiveRecord::Base
  has_many :tracks
  
  def self.find_paginated(page)
    paginate :per_page => 5, :order => "name ASC", :include => :tracks, :page => page
  end
end
