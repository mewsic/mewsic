ActionController::Routing::Routes.draw do |map|
  
  map.resources :mbands, :member => {:rate => :put, :set_leader => :put} do |mband|    
    mband.resource :avatar
    mband.resources :photos
    mband.resources :songs
    mband.resources :tracks, :member => { :toggle_idea => :put }
  end  
  
  map.connect 'mband_memberships/accept/:token', :controller => 'mband_memberships', :action => 'accept'
  map.resources :mband_memberships
  
  map.resources :answers, :member => { :rate => :put, :siblings => :get }, :collection => { :top => :get, :newest => :get, :open => :get, :search => :get } do |answers|
    answers.resources :replies
    answers.resources :abuses, :singular => 'abuse'
  end
  map.connect 'replies/:id/rate', :controller => 'replies', :action => 'rate'
  
  map.resources :genres do |genre|
    genre.resources :songs
  end
  
  map.resources :instruments
  map.resources :ideas, :collection => {:newest => :get, :coolest => :get, :by_instrument => :get}
  map.resources :bands_and_deejays
  map.resources :users, :collection => {:auto_complete_for_message_to => :get, :top => :get}, :member => {:switch_type => :any, :change_password => :put, :rate => :put} do |user|    
    user.resources :answers
    user.resources :songs
    user.resources :tracks, :member => { :toggle_idea => :put }
    user.resource  :avatar
    user.resources :members, :controller => 'band_members'
    user.resources :friendships
    user.resources :photos
    user.resources :mlabs
    user.resources :messages, :collection => { :delete_selected => :post, :sent => :get, :unread => :get }
  end
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id',  :controller => 'users', :action => 'reset_password'
    
  map.resources :sessions

  map.resources :songs, :has_one => :player, 
    :member => { :mix => :post, :load_track => :put, :unload_track => :put, :rate => :put , :tracks => :get, :download => :get } do |song|

    song.resources :abuses, :singular => 'abuse'
    
  end
 
  map.resources :tracks, :has_one => :player, :member => { :rate => :put, :download => :get }
  
  map.resources :search

  map.resources :avatars
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.music '/music', :controller => 'music', :action => 'index'
  map.top_music '/music/top', :controller => 'music', :action => 'top'

  map.multitrack         '/multitrack',             :controller => 'multitrack', :action => 'index'
  map.multitrack_edit    '/multitrack/:id',         :controller => 'multitrack', :action => 'edit'
  map.multitrack_config  '/request.config',         :controller => 'multitrack', :action => 'config'
  map.multitrack_refresh '/multitrack/refresh/:id', :controller => 'multitrack', :action => 'refresh'

  map.connect '/countries', :controller => 'users', :action => 'countries'
  
  map.resources :help, :member => { :ask => :post }
  map.ask_help '/help/ask', :controller => 'help', :action => 'ask'

  map.content '/content/:id', :controller => 'content', :action => 'show'

  map.root :controller => "dashboard"
  map.connect 'splash', :controller => 'dashboard', :action => 'splash'
  map.connect 'noop', :controller => 'dashboard', :action => 'noop'

  map.connect '/admin', :controller => 'admin/dashboard', :action => 'index'
  map.upload_admin_track '/admin/tracks/upload', :controller => 'admin/tracks', :action => 'upload', :conditions => { :method => :post }
  map.namespace(:admin) do |admin|
    admin.resources :songs, :member => { :mix => :put, :unmix => :put, :mp3 => :post }
    admin.resources :tracks
    admin.resources :users
    admin.resources :answers
    admin.resources :help_pages, :member => { :rearrange => :put }
    admin.resources :static_pages
  end

end
