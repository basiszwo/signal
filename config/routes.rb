Signal::Application.routes.draw do
  
  match '/projects/status.:format' => 'projects#status', :as => :projects_status
  resources :projects do
    resources :builds
    resources :deploys

    match 'build' => 'projects#build'
  end
  
  
  # match '/projects/:name/tmp/metric_fu/output/index.html' => '#index', :as => :metrics
  # match '/projects/:name/doc/specs.html' => '#index', :as => :specs
  # match '/projects/:name/doc/features.html' => '#index', :as => :features
  # match '/projects/:name/target/:name.war' => '#index', :as => :war

  ## old style routes
  # map.metrics  "/projects/:name/tmp/metric_fu/output/index.html", :controller => nil
  # map.specs    "/projects/:name/doc/specs.html",                  :controller => nil
  # map.features "/projects/:name/doc/features.html",               :controller => nil
  # map.war      "/projects/:name/target/:name.war",                :controller => nil
  ###
  
  root :to => 'projects#index'
  
end