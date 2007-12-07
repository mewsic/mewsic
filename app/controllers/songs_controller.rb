class SongsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        redirect_to music_path
      end
      
      format.xml do 
        @songs = Song.find :all
      end
    end
  end
end
