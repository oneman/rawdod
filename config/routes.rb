ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.resources :posts do |post|
      post.resources :comments 
  end
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "posts"

  map.connect '/signup', :controller => "user", :action => "signup"
  map.connect '/logout', :controller => "user", :action => "logout"
  map.connect '/login', :controller => "user", :action => "login"
  map.connect '/seen', :controller => "user", :action => "seen"
  map.connect '/homepages', :controller => "user", :action => "homepages"
  map.connect '/home/:user', :controller => "user", :action => "homepage"
  map.connect '/homepage/:user', :controller => "user", :action => "homepage"
  map.connect '/edit_homepage', :controller => "user", :action => "edit_homepage"
  map.connect '/inbox', :controller => "messages", :action => "inbox"
  map.connect '/send_message', :controller => "messages", :action => "send_message"
  map.connect '/send_message/to/:to', :controller => "messages", :action => "send_message"
  map.connect '/posts_by/:user', :controller => "posts", :action => "posts_by"
  map.connect '/imagebrowser', :controller => "posts", :action => "imagebrowser"

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
