ActionController::Routing::Routes.draw do |map|

  map.resources :answers, :has_many => [ :replies ]
  map.resources :genres
  map.resources :users
  map.resources :sessions
  map.resources :songs
  map.resources :tracks
  
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
