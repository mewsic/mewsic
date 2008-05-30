class SearchController < ApplicationController

  def index
    redirect_to '/'
  end
  
  def new
    redirect_to '/' if params[:q].blank?
    if params[:q].strip.blank?
      flash[:error] = 'You did not enter a search string' 
      redirect_to '/'
      return
    end

    type = params[:type] && params[:type].join(' ')
    redirect_to(:action => :show, :id => CGI::escape(params[:q]), :type => type)
  end

  def show
    @q = CGI::unescape(params[:id])
    def @q.to_breadcrumb; self; end

    @show_siblings_count = true

    @users, @songs, @tracks, @ideas = search(@q, params[:type] || [])
    @entries = %w(users songs tracks ideas).inject({}) do |h,x|
      count = instance_variable_get("@#{x}").total_entries rescue 0
      h.update(x.to_sym => count)
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          if %w[user song track idea].include? params[:type]
            render(:partial => "#{params[:type]}_results", :layout => false) and return
          end
        end
      end
      format.xml
    end
  end
  
private

  def search(q, types = [])
    [
      (types.empty? || types.include?('user')) ? User.search_paginated(q, :per_page => 6, :page => params[:page]) : nil,
      (types.empty? || (types.include?('song') || types.include?('music'))) ? Song.search_paginated(q, :per_page => 6, :page => params[:page]) : nil,
      (types.empty? || (types.include?('track') || types.include?('music'))) ? Track.search_paginated(q, :per_page => 6, :page => params[:page]) : nil,
      (types.empty? || types.include?('idea')) ? Track.search_paginated_ideas(q, :per_page => 6, :page => params[:page]) : nil
    ]
  end

end
