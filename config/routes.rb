ActionController::Routing::Routes.draw do |map|
  map.resources :mbands

  
  map.resources :answers, :member => { :rate => :put } do |answers|
    answers.resources :replies
  end  
  map.connect 'replies/:id/rate', :controller => 'replies', :action => 'rate'
  
  map.resources :genres
  map.resources :instruments
  map.resources :ideas
  map.resources :bands_and_deejays
  map.resources :users, :member => {:switch_type => :put, :rate => :put} do |user|    
    user.resources :members, :controller => 'band_members'
    user.resources :friendships
    user.resources :photos
    user.resources :avatars
    user.resources :mlabs
    user.resources :messages, :collection => { :delete_selected => :post, :sent => :get, :unread => :get }
  end
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id',  :controller => 'users', :action => 'reset_password'
    
  map.resources :sessions
  map.resources :songs, :has_one => :player, :member => { :rate => :put }
  map.resources :tracks, :has_one => :player, :member => { :rate => :put }
  
  map.resources :search
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.multitrack        '/users/:user_id/multitrack',     :controller => 'multitrack', :action => 'index'
  map.multitrack_config '/users/:user_id/request.config', :controller => 'users', :action => 'request_config'
  map.multitrack_config '/users/:user_id/multitrack/request.config', :controller => 'users', :action => 'request_config'
  
  map.music '/music', :controller => 'music', :action => 'index'

  map.connect '/countries', :controller => 'users', :action => 'countries'

  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  map.help 'help', :controller => 'help', :action => 'index'
  map.connect 'help/send', :controller => 'help', :action => 'send_mail'
  map.connect 'help/:id', :controller => 'help', :action => 'show'  

  map.root :controller => "dashboard"
  
end
