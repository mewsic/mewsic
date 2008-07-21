class SearchController < ApplicationController

  before_filter :check_valid_search_query, :except => :index

  def index
    redirect_to '/'
  end
  
  def new
    respond_to do |format|
      format.html do        
        type = params[:type] && params[:type].join(' ')
        redirect_to(:action => :show, :id => CGI::escape(@q), :type => type) and return
      end
      
     format.xml do
       @show_siblings_count = true

       if @advanced
         # Search string: 
         # instrument=instrument_id & genre=genre_id & country=italy & bpm=120 & key=key & author=pink+floyd & title=the+wall
         #
         songs_conditions_string, songs_conditions_vars = '1=1', {}
         tracks_conditions_string, tracks_conditions_vars = '1=1', {}

         if params[:instrument] && !params[:instrument].blank?
           tracks_conditions_string += ' AND tracks.instrument_id = :instrument'
           tracks_conditions_vars[:instrument] = params[:instrument]
         end
        
         if params[:genre] && !params[:genre].blank?
           songs_conditions_string += ' AND songs.genre_id = :genre'
           songs_conditions_vars[:genre] = params[:genre]
         end
        
         if params[:country] && !params[:country].blank?
           tracks_conditions_string += ' AND users.country = :country'
           songs_conditions_string += ' AND users.country = :country'
        
           tracks_conditions_vars[:country] = params[:country]
           songs_conditions_vars[:country] = params[:country]
         end
        
         if params[:bpm] && !params[:bpm].blank?
           tracks_conditions_string += ' AND tracks.bpm = :bpm'
           tracks_conditions_vars[:bpm] = params[:bpm].to_i
        
           songs_conditions_string += ' AND songs.bpm = :bpm'
           songs_conditions_vars[:bpm] = params[:bpm].to_i
         end
        
         if params[:key] && !params[:key].blank?
           tracks_conditions_string += ' AND tracks.tonality = :key'
           tracks_conditions_vars[:key] = params[:key]
        
           songs_conditions_string += ' AND songs.tone = :key'
           songs_conditions_vars[:key] = params[:key]
         end
        
         if params[:author] && !params[:author].blank?
           author = params[:author].gsub(/[%_]/){"\\#{$&}"}
        
           songs_conditions_string += ' AND songs.original_author LIKE :author'
           songs_conditions_vars[:author] = "%#{author}%"
         end
           
         if params[:title] && !params[:title].blank?
           title = params[:title].gsub(/[%_]/){"\\#{$&}"}
        
           tracks_conditions_string += ' AND tracks.title LIKE :title'
           tracks_conditions_vars[:title] = "%#{title}%"
        
           songs_conditions_string += ' AND songs.title LIKE :title'
           songs_conditions_vars[:title] = "%#{title}%"
         end
        
         @songs =
           if !songs_conditions_vars.empty?
             songs_conditions_string += ' AND published = :published'
             songs_conditions_vars[:published] = true

             Song.find(:all, :include => [:user, :genre],
                       :conditions => [songs_conditions_string, songs_conditions_vars],
                       :order => 'songs.rating_avg DESC, songs.created_at DESC', :limit => 20)
           else
             []
           end

         @tracks =
           if !tracks_conditions_vars.empty?
             Track.find(:all, :include => [{:parent_song => :genre}, :owner, :instrument],
                        :conditions => [tracks_conditions_string, tracks_conditions_vars],
                        :order => 'tracks.rating_avg DESC, tracks.created_at DESC', :limit => 20)
           else 
             []
           end

       else

         @songs = Song.search(@q, :include => [:genre, :mixes, :user], :limit => 20, :order => 'songs.rating_avg DESC, songs.created_at DESC')
         @tracks = Track.search(@q, :include => [:instrument, {:parent_song => :genre}, :owner], :limit => 20, :order => 'tracks.rating_avg DESC, tracks.created_at DESC')

       end
       render :action => 'show'
     end
    end
  end

  def show
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

  private
    def search(q, types = [])
      [
        (types.empty? || types.include?('user')) ?                               User.search_paginated(q,        :per_page => 10, :page => params[:page]) : nil,
        (types.empty? || (types.include?('song') || types.include?('music'))) ?  Song.search_paginated(q,        :per_page => 10, :page => params[:page]) : nil,
        (types.empty? || (types.include?('track') || types.include?('music'))) ? Track.search_paginated(q,       :per_page => 10, :page => params[:page]) : nil,
        (types.empty? || types.include?('idea')) ?                               Track.search_paginated_ideas(q, :per_page => 10, :page => params[:page]) : nil
      ]
    end

    # instrument=instrument_id&genre=genre_id&country=country&city=city&author=pink+floyd&title=the+wall
    def check_valid_search_query
      @q = CGI::unescape(params.delete(:q) || params.delete(:id) || '')
      @q.gsub! /%/, ''

      @advanced = params.any? { |k,v| %w(instrument genre country city author title).include?(k) }

      if @q.strip.blank? && !@advanced
        flash[:error] = 'You did not enter a search string' 
        respond_to do |format|
          format.html { redirect_to '/' and return }
          format.xml { render :nothing => true, :status => :bad_request }
        end
      end
    end

end
