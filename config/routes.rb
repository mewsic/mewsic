ActionController::Routing::Routes.draw do |map|
  
  map.resources :mbands, :member => {:rate => :put, :set_leader => :put} do |mband|    
    mband.resource :avatar
    mband.resources :photos
    mband.resources :songs
    mband.resources :tracks
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
  map.resources :ideas, :collection => {:newest => :get, :coolest => :get}
  map.resources :bands_and_deejays
  map.resources :users, :collection => {:auto_complete_for_message_to => :get}, :member => {:switch_type => :any, :rate => :put} do |user|    
    user.resources :answers
    user.resources :songs
    user.resources :tracks
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
    :member => { :mix => :post, :rate => :put , :direct_sibling_tracks => :get, :indirect_sibling_tracks => :get, :download => :get } do |song|

    song.resources :abuses, :singular => 'abuse'
    
  end
  
  #map.connect 'songs/:id/mix', :controller => 'songs', :action => 'mix'
  
  map.resources :tracks, :has_one => :player, :member => { :rate => :put, :download => :get }
  
  map.resources :search

  map.resources :avatars
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.music '/music', :controller => 'music', :action => 'index'

  map.multitrack        '/multitrack',          :controller => 'multitrack', :action => 'index'
  map.multitrack_edit   '/multitrack/:song_id', :controller => 'multitrack', :action => 'edit'
  map.multitrack_config '/request.config',      :controller => 'multitrack', :action => 'config'

  map.connect '/countries', :controller => 'users', :action => 'countries'
  
  map.help 'help', :controller => 'help', :action => 'index'
  map.connect 'help/send', :controller => 'help', :action => 'send_mail'
  map.connect 'help/:id', :controller => 'help', :action => 'show'  

  map.root :controller => "dashboard"
  map.connect 'splash', :controller => 'dashboard', :action => 'splash'
  map.connect 'noop', :controller => 'dashboard', :action => 'noop'

  map.connect '/admin', :controller => 'admin/dashboard', :action => 'index'
  map.namespace(:admin) do |admin|
    admin.resources :songs
    admin.resources :tracks
    admin.resources :users
    admin.resources :answers
  end

end
