ActionController::Routing::Routes.draw do |map|

  map.resources :answers, :has_many => [ :replies ]
  map.resources :genres
  map.resources :instruments
  map.resources :users do |user|    
    user.resources :friendships
    user.resources :photos
    user.resources :avatars
    user.resources :mlabs
    user.resources :messages, :collection => { :delete_selected => :post, :sent => :get }
  end
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id',  :controller => 'users', :action => 'reset_password'
    
  map.resources :sessions
  map.resources :songs
  map.resources :tracks 
  
  map.resources :search
  
  map.connect 'login', :controller => 'sessions', :action => 'new'
    
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.multitrack '/multitrack', :controller => 'multitrack', :action => 'index'
  
  map.music '/music', :controller => 'music', :action => 'index'

  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.root :controller => "dashboard"
  
end
