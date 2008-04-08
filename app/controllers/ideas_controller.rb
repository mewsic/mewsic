class IdeasController < ApplicationController

  def index
    @newest   = Track.find_orphans(:limit => 3, :order => "tracks.created_at DESC")
    @coolest  = Track.find_orphans(:limit => 3, :order => "tracks.created_at DESC")
  end
end
