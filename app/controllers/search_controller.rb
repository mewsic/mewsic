class SearchController < ApplicationController
  
  def new
    redirect_to '/' and return if params[:q].strip.blank?
    redirect_to(:action => :show, :id => CGI::escape(params[:q]))
  end

  def show
    @q = CGI::unescape(params[:id])
    @show_siblings_count = true
    @users, @songs, @tracks, @ideas = search(@q, params[:type])
    respond_to do |format|
      format.html do
        if %w[user song track track idea].include?(params[:type])
          render(:partial => "#{params[:type]}_results", :layout => false) and return
        end
      end
      format.xml
    end
  end

private

  def search(q, only = nil)    
    [
      (only.nil? || only == 'user') ? User.search_paginated(q, :per_page => 6, :page => params[:page]) : nil,
      (only.nil? || only == 'song') ? Song.search_paginated(q, :per_page => 6, :page => params[:page]) : nil,
      (only.nil? || only == 'track') ? Track.search_paginated(q, :per_page => 6, :page => params[:page]) : nil,
      (only.nil? || only == 'idea') ? Track.search_paginated_ideas(q, :per_page => 6, :page => params[:page]) : nil
    ]
  end
  
end
