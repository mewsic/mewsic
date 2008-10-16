# Myousica Search controller.
#
# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# == Description
# This controller implements the search engine interface of the site. It has HTML and XML output,
# for browsers and for the multitrack SWF. The backend uses Sphinx for full-text indexing of the
# database. See the +show+ method for details on search query format and Sphinx interaction.
#
# Sanity checks for the search query are carried out in the +check_valid_search_query+ filter.
#
class SearchController < ApplicationController

  before_filter :check_valid_search_query

  # ==== GET /search?q=query
  # ==== GET /search.xml?q=query & instrument=instrument_id & genre=genre_id & country=italy & bpm=120 & key=C# & author=pink+floyd & title=the+wall
  #
  # This action performs a search and shows the results, in HTML and XML format. The former is for
  # browsers, the latter for the Multitrack SWF. The HTML output accepts a <tt>type</tt> parameter
  # to show only specific kinds of results. If it's an array, it can contain 4 strings: <tt>users
  # </tt>, <tt>songs</tt>, <tt>tracks</tt> and <tt>ideas</tt>, generated by the "advanced search"
  # checkboxes located in the nav menu.
  #
  # If the type parameter is a bare string instead, it is used for the pagination of the results.
  #
  # The XML format accepts more advanced query parameters, in order to implement the multitrack
  # advanced search. They are:
  #
  #  * <tt>instrument</tt>: an instrument id
  #  * <tt>genre</tt>: a genre id
  #  * <tt>country</tt>: a country string, searched full-text via sphinx
  #  * <tt>bpm</tt>: a beats per minute integer
  #  * <tt>key</tt>: one of Myousica::TONES, converted into an integer by Myousica::key
  #  * <tt>author</tt>: an author string, searched full-text via sphinx
  #  * <tt>title</tt>: a title string, searched full-text via sphinx
  #
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

       @songs  = search_songs(@q, 30, 1, songs_conditions)
       @tracks = search_tracks(@q, 30, 1, tracks_conditions)

       render :action => 'show'
     end
    end
  end

  private
    # Helper to search users, songs, tracks and ideas with the given query string. The
    # types array contains which different kind of models perform the search on.
    # Searches are paginated, this helper uses params[:page] and passes it on to
    # +search_users+, +search_songs+, +search_tracks+ and +search_ideas+.
    #
    def search(q, types = [])
      [
        (types.empty? || types.include?('user')) ?                               search_users(q, 10, params[:page] || 1) : nil,
        (types.empty? || (types.include?('song') || types.include?('music'))) ?  search_songs(q, 10, params[:page] || 1) : nil,
        (types.empty? || (types.include?('track') || types.include?('music'))) ? search_tracks(q, 10, params[:page] || 1) : nil,
        (types.empty? || types.include?('idea')) ?                               search_ideas(q, 10, params[:page] || 1) : nil
      ]
    end

    # Helper that searches the users index. Returns an Array of User objects.
    #
    #  * <tt>query</tt>: sphinx query string
    #  * <tt>per_page</tt>: number of results per page
    #  * <tt>page</tt>: page number to show
    #
    def search_users(query, per_page, page)
      User.search(query, :per_page => per_page, :page => page, :index => 'users', :match_mode => :boolean).compact
    end

    # Helper that searches the songs index. Returns an Array of Song objects.
    #
    #  * <tt>query</tt>: sphinx query string
    #  * <tt>per_page</tt>: number of results per page
    #  * <tt>page</tt>: page number to show
    #
    def search_songs(query, per_page, page, conditions = {})
      Song.search(query, :per_page => per_page, :page => page, :index => 'songs', :match_mode => :extended, :include => :user, :conditions => conditions).compact
    end

    # Helper that searches the tracks index. Returns an Array of Track objects.
    #
    #  * <tt>query</tt>: sphinx query string
    #  * <tt>per_page</tt>: number of results per page
    #  * <tt>page</tt>: page number to show
    #
    def search_tracks(query, per_page, page, conditions = {})
      Track.search(query, :per_page => per_page, :page => page, :index => 'tracks', :match_mode => :extended, :conditions => conditions).compact
    end

    # Helper that searches the tracks index, returning only ones where the <tt>idea</tt> attribute is <tt>1</tt>.
    # Returns an Array of Track objects.
    #
    #  * <tt>query</tt>: sphinx query string
    #  * <tt>per_page</tt>: number of results per page
    #  * <tt>page</tt>: page number to show
    #
    def search_ideas(query, per_page, page)
      Track.search(query, :per_page => per_page, :page => page, :index => 'tracks', :match_mode => :boolean, :conditions => { :idea => '1' } ).compact
    end

    # Filter that checks that the search query is not blank. The string is unescaped with CGI::unescape, and
    # every <tt>%</tt> char is removed. The result is saved into the <tt>@q</tt> instance variable.
    #
    # If the query results blank, and none of the advanced search parameter is set, the HTML format redirects
    # the user to <tt>'/'</tt> while the XML one renders nothing with a 400 status.
    #
    def check_valid_search_query
      # instrument=instrument_id&genre=genre_id&country=country&city=city&author=pink+floyd&title=the+wall
      #
      @q = CGI::unescape(params.delete(:q) || '')
      @q.gsub! /%/, ''

      advanced = params.any? { |k,v| %w(instrument bpm genre country city author title key).include?(k) }
      if @q.strip.blank? && !advanced
        flash[:error] = 'You did not enter a search string'
        respond_to do |format|
          format.html { redirect_to '/' }
          format.xml { render :nothing => true, :status => :bad_request }
        end
      end
    end

end
