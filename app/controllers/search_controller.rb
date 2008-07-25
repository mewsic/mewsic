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
       
       songs_conditions = {}
       tracks_conditions = {}
       
       if @advanced
         songs_conditions[:genre_id]        = params[:genre].to_i if params.include?(:genre) && !params[:genre].blank?
         if params.include?(:bpm) && !params[:bpm].blank?
           songs_conditions[:bpm] = params[:bpm].to_i   
           tracks_conditions[:bpm] = params[:bpm].to_i
         end
         if params.include?(:key) && !params[:key].blank? && key = Myousica::TONES.index(params[:key].to_s.upcase)
           songs_conditions[:key] = key
           tracks_conditions[:key] = key
         end
       end

       @songs =   search_songs(@q, 10, 1, songs_conditions)
       @tracks =  search_tracks(@q, 10, 1, tracks_conditions)
        
       #if @advanced         
         # Search string: 
         # instrument=instrument_id & genre=genre_id & country=italy & bpm=120 & key=key & author=pink+floyd & title=the+wall
         #
         
         # songs_conditions_string, songs_conditions_vars = '1=1', {}
         #          tracks_conditions_string, tracks_conditions_vars = '1=1', {}
         # 
         #          if params[:instrument] && !params[:instrument].blank?
         #            tracks_conditions_string += ' AND tracks.instrument_id = :instrument'
         #            tracks_conditions_vars[:instrument] = params[:instrument]
         #          end
         #         
         #          if params[:genre] && !params[:genre].blank?
         #            songs_conditions_string += ' AND songs.genre_id = :genre'
         #            songs_conditions_vars[:genre] = params[:genre]
         #          end
         #         
         #          if params[:country] && !params[:country].blank?
         #            tracks_conditions_string += ' AND users.country = :country'
         #            songs_conditions_string += ' AND users.country = :country'
         #         
         #            tracks_conditions_vars[:country] = params[:country]
         #            songs_conditions_vars[:country] = params[:country]
         #          end
         #         
         #          if params[:bpm] && !params[:bpm].blank?
         #            tracks_conditions_string += ' AND tracks.bpm = :bpm'
         #            tracks_conditions_vars[:bpm] = params[:bpm].to_i
         #         
         #            songs_conditions_string += ' AND songs.bpm = :bpm'
         #            songs_conditions_vars[:bpm] = params[:bpm].to_i
         #          end
         #         
         #          if params[:key] && !params[:key].blank?
         #            tracks_conditions_string += ' AND tracks.tonality = :key'
         #            tracks_conditions_vars[:key] = params[:key]
         #         
         #            songs_conditions_string += ' AND songs.tone = :key'
         #            songs_conditions_vars[:key] = params[:key]
         #          end
         #         
         #          if params[:author] && !params[:author].blank?
         #            author = params[:author].gsub(/[%_]/){"\\#{$&}"}
         #         
         #            songs_conditions_string += ' AND songs.original_author LIKE :author'
         #            songs_conditions_vars[:author] = "%#{author}%"
         #          end
         #            
         #          if params[:title] && !params[:title].blank?
         #            title = params[:title].gsub(/[%_]/){"\\#{$&}"}
         #         
         #            tracks_conditions_string += ' AND tracks.title LIKE :title'
         #            tracks_conditions_vars[:title] = "%#{title}%"
         #         
         #            songs_conditions_string += ' AND songs.title LIKE :title'
         #            songs_conditions_vars[:title] = "%#{title}%"
         #          end
        
         # @songs =
         #   if !songs_conditions_vars.empty?
         #     songs_conditions_string += ' AND published = :published'
         #     songs_conditions_vars[:published] = true
         # 
         #     Song.find(:all, :include => [:user, :genre],
         #               :conditions => [songs_conditions_string, songs_conditions_vars],
         #               :order => 'songs.rating_avg DESC, songs.created_at DESC', :limit => 20)
         #   else
         #     []
         #   end
         
         # filter = {}
         #          filter["genre_id"] = params[:genre_id].to_i if params.include?(:genre)
         #          @songs = Song.paginate_with_sphinx(@q, :include => [:genre, :mixes, :user], :order => 'songs.rating_avg DESC, songs.created_at DESC',
         #            :sphinx => {
         #              :page => 1,
         #              :limit => 20,
         #              :filter => {
         #                'genre_id' => 961712978
         #              }
         #            }           
         #           )
         # 
         #          @tracks =
         #            if !tracks_conditions_vars.empty?
         #              Track.find(:all, :include => [{:parent_song => :genre}, :owner, :instrument],
         #                         :conditions => [tracks_conditions_string, tracks_conditions_vars],
         #                         :order => 'tracks.rating_avg DESC, tracks.created_at DESC', :limit => 20)
         #            else 
         #              []
         #            end
         # 
         #        else
         # 
         #          @songs = Song.paginate_with_sphinx(@q, :include => [:genre, :mixes, :user], :order => 'songs.rating_avg DESC, songs.created_at DESC',
         #           :sphinx => {
         #             :page => 1,
         #             :limit => 20
         #           }
         #          )
         #          @tracks = Track.search(@q, :include => [:instrument, {:parent_song => :genre}, :owner], :limit => 20, :order => 'tracks.rating_avg DESC, tracks.created_at DESC')

       #end
       
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
        (types.empty? || types.include?('user')) ?                               search_users(q, 10, params[:page] || 1) : nil,
        (types.empty? || (types.include?('song') || types.include?('music'))) ?  search_songs(q, 10, params[:page] || 1) : nil,
        (types.empty? || (types.include?('track') || types.include?('music'))) ? search_tracks(q, 10, params[:page] || 1) : nil,
        (types.empty? || types.include?('idea')) ?                               search_ideas(q, 10, params[:page] || 1) : nil
      ]
    end
    
    def search_users(query, per_page, page)
      User.search(query, :per_page => per_page, :page => page, :index => 'users', :match_mode => :boolean)
    end
    
    def search_songs(query, per_page, page, conditions = {})                        
      Song.search(query, :per_page => per_page, :page => page, :index => 'songs', :match_mode => :extended, :include => :user, :conditions => conditions)
    end
    
    def search_tracks(query, per_page, page, conditions = {})
      Track.search(query, :per_page => per_page, :page => page, :index => 'tracks', :match_mode => :boolean, :conditions => conditions)
    end
    
    def search_ideas(query, per_page, page)
      Track.search(query, :per_page => per_page, :page => page, :index => 'tracks', :match_mode => :boolean, :conditions => { :idea => '1' } )
    end

    # instrument=instrument_id&genre=genre_id&country=country&city=city&author=pink+floyd&title=the+wall
    def check_valid_search_query
      @q = CGI::unescape(params.delete(:q) || params.delete(:id) || '')
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
