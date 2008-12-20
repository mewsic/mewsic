ActionController::Routing::Routes.draw do |map|
  
  map.resources :mbands, :member => {:rate => :put, :set_leader => :put} do |mband|    
    mband.resource :avatar
    mband.resources :photos
    mband.resources :songs
    mband.resources :tracks
  end  
  map.mband_podcast '/mbands/:mband_id/podcast.xml', :controller => 'podcasts', :action => 'show', :conditions => {:method => :get}
  
  map.accept_mband_membership 'mband_memberships/accept/:token', :controller => 'mband_memberships', :action => 'accept'
  map.decline_mband_membership 'mband_memberships/decline/:token', :controller => 'mband_memberships', :action => 'decline'
  map.resources :mband_memberships
  
  map.answers_rss 'answers/rss.xml', :controller => 'answers', :action => 'rss'
  map.resources :answers, :member => { :rate => :put, :siblings => :get }, :collection => { :top => :get, :newest => :get, :open => :get, :search => :get } do |answer|
    answer.resources :replies
    answer.resources :abuses
  end
  map.rate_reply 'replies/:id/rate', :controller => 'replies', :action => 'rate', :conditions => { :method => :put }
  
  map.resources :genres do |genre|
    genre.resources :songs
    genre.rss 'rss.xml', :controller => 'genres', :action => 'rss'
  end
  
  map.resources :instruments
  map.resources :ideas, :collection => {:newest => :get, :coolest => :get, :by_instrument => :get}
  map.resources :bands_and_deejays, :collection => {:newest => :get, :coolest => :get, :prolific => :get, :best => :get}
  map.resources :users, :collection => {:auto_complete_for_message_to => :get, :top => :get, :newest => :get, :best => :get, :coolest => :get, :prolific => :get}, :member => {:firstrun => :get, :switch_type => :any, :change_password => :put, :rate => :put} do |user|    
    user.resources :answers
    user.resources :songs
    user.resources :tracks
    user.resource  :avatar
    user.resources :members, :controller => 'band_members'
    user.resources :friendships
    user.resources :photos
    user.resources :mlabs
    user.resources :messages, :collection => { :delete_selected => :post, :sent => :get, :unread => :get }
    user.resources :abuses
  end
  map.user_podcast '/users/:user_id/podcast.xml', :controller => 'podcasts', :action => 'show', :conditions => {:method => :get}
  map.user_pcast '/users/:user_id/:user_id.pcast', :controller => 'podcasts', :action => 'pcast', :conditions => {:method => :get}
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id',  :controller => 'users', :action => 'reset_password'
    
  map.resources :sessions

  map.resources :songs, :has_one => :player, 
    :member => { :mix => :post, :load_track => :put, :unload_track => :put, :rate => :put , :tracks => :get, :download => :get, :confirm_destroy => :get } do |song|
    song.resources :abuses
    song.increment 'i', :controller => 'players', :action => 'increment' #, :conditions => {:method => :put}
  end
 
  map.resources :tracks, :has_one => :player, :member => { :rate => :put, :toggle_idea => :put, :download => :get, :confirm_destroy => :get } do |track|
    track.resources :abuses
    track.increment 'i', :controller => 'players', :action => 'increment' #, :conditions => {:method => :put}
  end
  
  map.search '/search', :controller => 'search', :action => 'show', :format => 'html', :conditions => { :method => :get }
  map.formatted_search '/search.:format', :controller => 'search', :action => 'show', :conditions => { :method => :get }

  map.resources :avatars
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.music        '/music',         :controller => 'music', :action => 'index'
  map.top_music    '/music/top',     :controller => 'music', :action => 'top'
  map.newest_music '/music/newest/', :controller => 'music', :action => 'newest'

  map.multitrack         '/multitrack',             :controller => 'multitrack', :action => 'index'
  map.multitrack_edit    '/multitrack/:id',         :controller => 'multitrack', :action => 'edit'
  map.multitrack_config  '/multitrack.xml',         :controller => 'multitrack', :action => 'config', :format => 'xml'
  map.multitrack_refresh '/multitrack/refresh/:id', :controller => 'multitrack', :action => 'refresh'
  map.multitrack_auth    '/multitrack/_/:user_id',  :controller => 'multitrack', :action => 'authorize'
  map.multitrack_song    '/multitrack/s/:user_id',  :controller => 'multitrack', :action => 'update_song'
  map.multitrack_beta    '/pappapperotrack',        :controller => 'multitrack', :action => 'beta_index'
  map.multitrack_beta    '/pappapperotrack/:id',    :controller => 'multitrack', :action => 'beta_edit'

  map.splash_config '/splash.xml', :controller => 'dashboard', :action => 'config', :format => 'xml'

  map.connect '/countries.:format', :controller => 'users', :action => 'countries'
  
  map.resources :help, :member => { :ask => :post }
  map.ask_help '/help/ask', :controller => 'help', :action => 'ask'

  map.content '/content/:id', :controller => 'content', :action => 'show'

  map.root                              :controller => 'dashboard'
  map.noop            '/noop/:id',      :controller => 'dashboard', :action => 'noop'
  map.top_myousicians '/top',           :controller => 'dashboard', :action => 'top'
  map.landing         '/index/:origin', :controller => 'dashboard', :action => 'track'
  map.index           '/index.:format', :controller => 'dashboard'
  map.connect         '/index',         :controller => 'dashboard'

  map.sitemap         '/sitemap.xml',   :controller => 'sitemap', :format => 'xml'

  map.admin '/pappapperadmin', :controller => 'admin/dashboard', :action => 'index'
  map.upload_admin_track '/pappapperadmin/admin/tracks/upload', :controller => 'admin/tracks', :action => 'upload', :conditions => { :method => :post }
  map.namespace(:admin, :namespace => '', :name_prefix => '', :path_prefix => 'pappapperadmin') do |admin|
    admin.resources :songs, :member => { :mix => :put, :unmix => :put, :mp3 => :post }
    admin.resources :tracks
    admin.resources :users
    admin.resources :answers
    admin.resources :help_pages, :member => { :rearrange => :put }
    admin.resources :static_pages
    admin.resources :videos, :member => { :rearrange => :put }
  end

end
