class SearchController < ApplicationController

  before_filter :check_valid_search_query

  def show
    respond_to do |format|
      format.html do        
        def @q.to_breadcrumb; self; end

        @users, @songs, @tracks, @ideas = search(@q, params[:type] || [])
        @entries = %w(users songs tracks ideas).inject({}) do |h,x|
          count = instance_variable_get("@#{x}").total_entries rescue 0
          h.update(x.to_sym => count)
        end

        if request.xhr? && %w[user song track idea].include?(params[:type])
          render(:partial => "#{params[:type]}_results", :layout => false) and return
        end
      end
      
     format.xml do
       @show_siblings_count = true
       
       songs_conditions = {}
       tracks_conditions = {}
       
       if @advanced
         # Search string:
         # instrument=instrument_id & genre=genre_id & country=italy & bpm=120 & key=key & author=pink+floyd & title=the+wall
         #
         if params.include?(:genre) && !params[:genre].blank?
           songs_conditions[:genre_id] = params[:genre].to_i
         end
         if params.include?(:bpm) && !params[:bpm].blank?
           songs_conditions[:bpm] = params[:bpm].to_i   
           tracks_conditions[:bpm] = params[:bpm].to_i
         end
         if params.include?(:key) && !params[:key].blank? && key = Myousica::TONES.index(params[:key].to_s.upcase)
           songs_conditions[:key] = key
           tracks_conditions[:key] = key
         end
         if params.include?(:instrument) && !params[:instrument].blank?  
           tracks_conditions[:instrument_id] = params[:instrument].to_i
         end
         if params.include?(:title) && !params[:title].blank?  
           @q = "#{@q} @title #{params[:title]}"
         end
         if params.include?(:author) && !params[:author].blank?  
           @q = "#{@q} @author #{params[:author]}"
         end
         if params.include?(:country) && !params[:country].blank?
           @q = "#{@q} @user_country #{params[:country]}"
         end
       end      

       @songs  = search_songs(@q, 30, 1, songs_conditions)
       @tracks = search_tracks(@q, 30, 1, tracks_conditions)
        
       render :action => 'show'
     end
    end
  end

  private
    def search(q, types = [])
      [
        (types.empty? || types.include?('user')) ?                               search_users(q, 10, params[:page] || 1) : nil,
        (types.empty? || (types.include?('song') || types.include?('music'))) ?  search_songs(q, 10, params[:page] || 1) : nil,
        (types.empty? || (types.include?('track') || types.include?('music'))) ? search_tracks(q, 10, params[:page] || 1) : nil,
        (types.empty? || types.include?('idea')) ?                               search_ideas(q, 10, params[:page] || 1) : nil
      ]
    end
    
    def search_users(query, per_page, page)
      User.search(query, :per_page => per_page, :page => page, :index => 'users', :match_mode => :boolean).compact
    end
    
    def search_songs(query, per_page, page, conditions = {})                        
      Song.search(query, :per_page => per_page, :page => page, :index => 'songs', :match_mode => :extended, :include => :user, :conditions => conditions).compact
    end
    
    def search_tracks(query, per_page, page, conditions = {})
      Track.search(query, :per_page => per_page, :page => page, :index => 'tracks', :match_mode => :extended, :conditions => conditions).compact
    end
    
    def search_ideas(query, per_page, page)
      Track.search(query, :per_page => per_page, :page => page, :index => 'tracks', :match_mode => :boolean, :conditions => { :idea => '1' } ).compact
    end

    def check_valid_search_query
      # instrument=instrument_id&genre=genre_id&country=country&city=city&author=pink+floyd&title=the+wall
      #
      @q = CGI::unescape(params.delete(:q) || '')
      @q.gsub! /%/, ''

      @advanced = params.any? { |k,v| %w(instrument bpm genre country city author title key).include?(k) }

      if @q.strip.blank? && !@advanced
        flash[:error] = 'You did not enter a search string' 
        respond_to do |format|
          format.html { redirect_to '/' and return }
          format.xml { render :nothing => true, :status => :bad_request }
        end
      end
    end

end
