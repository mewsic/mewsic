class SearchController < ApplicationController

  before_filter :check_valid_search_string, :except => :index

  def index
    redirect_to '/'
  end
  
  def new
    respond_to do |format|
      format.html do        
        type = params[:type] && params[:type].join(' ')
        redirect_to(:action => :show, :id => CGI::escape(params[:q]), :type => type) and return
      end
      
     format.xml do
       @show_siblings_count = true
       @songs = Song.search_paginated(params[:q], :per_page => 6, :page => params[:page])
       @tracks = Track.search_paginated(params[:q], :per_page => 6, :page => params[:page])
       render :action => 'show'
     end
    end
  end

  def show
    @q = CGI::unescape(params[:id])
    def @q.to_breadcrumb; self; end

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

  protected
    def check_valid_search_string
      query = params[:q] || params[:id] || ''
      query.gsub! /[%_]/, ''
      if query.strip.blank?
        flash[:error] = 'You did not enter a search string' 
        respond_to do |format|
          format.html { redirect_to '/' and return }
          format.xml { render :nothing => true, :status => :bad_request }
        end
      end
    end
  
  private
    def search(q, types = [])
      [
        (types.empty? || types.include?('user')) ?                               User.search_paginated(q,        :per_page => 10, :page => params[:page]) : nil,
        (types.empty? || (types.include?('song') || types.include?('music'))) ?  Song.search_paginated(q,        :per_page => 10, :page => params[:page]) : nil,
        (types.empty? || (types.include?('track') || types.include?('music'))) ? Track.search_paginated(q,       :per_page => 10, :page => params[:page]) : nil,
        (types.empty? || types.include?('idea')) ?                               Track.search_paginated_ideas(q, :per_page => 10, :page => params[:page]) : nil
      ]
    end

end
