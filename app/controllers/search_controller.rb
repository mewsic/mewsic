class SearchController < ApplicationController

  def show
    @show_siblings_count = true
    @users, @songs, @tracks = search(params[:type])
    puts "*"*50
    puts @tracks.inspect
    puts "*"*50
    respond_to do |format|
      format.html do
        if request.xhr? && params[:type]
          case params[:type]
            when 'user'   then render(:partial => 'user_results', :layout => false) and return
            when 'song'   then render(:partial => 'song_results', :layout => false) and return
            when 'track'  then render(:partial => 'track_results', :layout => false) and return
          end
        end
      end
      format.xml
    end
  end

private

  def search(only = nil)    
    [
      (only.nil? || only == 'user') ? User.search_paginated(params[:id], :per_page => 6, :page => params[:page]) : nil,
      (only.nil? || only == 'song') ? Song.search_paginated(params[:id], :per_page => 6, :page => params[:page]) : nil,
      (only.nil? || only == 'track') ? Track.search_paginated(params[:id], :per_page => 6, :page => params[:page]) : nil
    ]
  end
  
end
