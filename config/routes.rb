ActionController::Routing::Routes.draw do |map|

  # Songs
  #
  map.resources :songs, :has_one => :player,
    :member => { :mix => :post, :load_track => :put, :unload_track => :put, :rate => :put , :tracks => :get, :download => :get, :confirm_destroy => :get } do |song|
    song.resources :abuses
    song.resources :comments
    song.increment 'i', :controller => 'players', :action => 'increment' #, :conditions => {:method => :put}
  end

  # Tracks
  #
  map.resources :tracks, :has_one => :player, :member => { :rate => :put, :toggle_idea => :put, :download => :get, :confirm_destroy => :get } do |track|
    track.resources :abuses
    track.resources :comments
    track.increment 'i', :controller => 'players', :action => 'increment' #, :conditions => {:method => :put}
  end

  # Users
  #
  map.resources :users, :collection => {:auto_complete_for_message_to => :get, :top => :get, :newest => :get, :best => :get, :coolest => :get, :prolific => :get}, :member => {:firstrun => :get, :change_password => :put, :rate => :put} do |user|
    user.resources :answers
    user.resources :songs
    user.resources :tracks
    user.resource  :avatar
    user.resources :friendships
    user.resources :photos
    user.resources :mlabs, :as => 'playlist'
    user.resources :messages, :collection => { :delete_selected => :post, :sent => :get, :unread => :get }
    user.resources :abuses
    user.resources :comments
  end

  # Mbands && memberships
  #
  map.resources :mbands, :member => {:rate => :put, :set_leader => :put} do |mband|
    mband.resource :avatar
    mband.resources :photos
    mband.resources :songs
    mband.resources :tracks
    mband.resources :comments
  end

  map.resources :mband_memberships
  map.accept_mband_membership 'mband_memberships/accept/:token', :controller => 'mband_memberships', :action => 'accept'
  map.decline_mband_membership 'mband_memberships/decline/:token', :controller => 'mband_memberships', :action => 'decline'

  # Answers
  #
  map.resources :answers, :member => { :rate => :put, :siblings => :get }, :collection => { :top => :get, :newest => :get, :open => :get, :search => :get } do |answer|
    answer.resources :abuses
    answer.resources :comments
  end

  # Minor objects
  #
  map.resources :comments, :member => { :rate => :put }
  map.resources :instruments
  map.resources :avatars
  map.resources :help, :member => { :ask => :post }
  map.ask_help '/help/ask', :controller => 'help', :action => 'ask'

  # Login / logout
  #
  map.resources :sessions
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # Search
  #
  map.search '/search', :controller => 'search', :action => 'show', :format => 'html', :conditions => { :method => :get }
  map.formatted_search '/search.:format', :controller => 'search', :action => 'show', :conditions => { :method => :get }

  # XML output - Multitrack
  #
  map.multitrack         '/multitrack',             :controller => 'multitrack', :action => 'index'
  map.multitrack_edit    '/multitrack/:id',         :controller => 'multitrack', :action => 'edit'
  map.multitrack_config  '/multitrack.xml',         :controller => 'multitrack', :action => 'config', :format => 'xml'
  map.multitrack_refresh '/multitrack/refresh/:id', :controller => 'multitrack', :action => 'refresh'
  map.multitrack_auth    '/multitrack/_/:user_id',  :controller => 'multitrack', :action => 'authorize'
  map.multitrack_song    '/multitrack/s/:user_id',  :controller => 'multitrack', :action => 'update_song'

  # XML output - Podcasts, RSS, Sitemap
  #
  map.answers_rss 'answers/rss.xml', :controller => 'answers', :action => 'rss'
  map.mband_podcast '/mbands/:mband_id/podcast.xml', :controller => 'podcasts', :action => 'show', :conditions => {:method => :get}
  map.user_podcast '/users/:user_id/podcast.xml', :controller => 'podcasts', :action => 'show', :conditions => {:method => :get}
  #map.user_pcast '/users/:user_id/:user_id.pcast', :controller => 'podcasts', :action => 'pcast', :conditions => {:method => :get}
  map.sitemap         '/sitemap.xml',   :controller => 'sitemap', :format => 'xml'

  # Signup / Activation
  #
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id',  :controller => 'users', :action => 'reset_password'

  # Static pages
  #
  map.content '/content/:id', :controller => 'content', :action => 'show'

  # Root & Landing
  map.root                              :controller => 'dashboard'
  map.noop            '/noop/:id',      :controller => 'dashboard', :action => 'noop'
  map.landing         '/index/:origin', :controller => 'dashboard', :action => 'track'
  map.index           '/index.:format', :controller => 'dashboard'
  map.connect         '/index',         :controller => 'dashboard'

  # Admin interface
  #
  map.admin '/admin', :controller => 'admin/dashboard', :action => 'index'
  map.upload_admin_track '/admin/admin/tracks/upload', :controller => 'admin/tracks', :action => 'upload', :conditions => { :method => :post }
  map.namespace(:admin, :namespace => '', :name_prefix => '', :path_prefix => 'admin') do |admin|
    admin.resources :songs, :member => { :mix => :put, :unmix => :put, :mp3 => :post }
    admin.resources :tracks
    admin.resources :users
    admin.resources :answers
    admin.resources :help_pages, :member => { :rearrange => :put }
    admin.resources :static_pages
    admin.resources :videos, :member => { :rearrange => :put }
    admin.resources :mass_messages
  end

end
