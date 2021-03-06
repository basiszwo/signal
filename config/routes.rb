ActionController::Routing::Routes.draw do |map|
  map.projects_status "/projects/status.:format", :controller => :projects, :action => :status
  map.resources :projects do |project|
    project.resources :builds
    project.resources :deploys
    project.connect 'build', :controller => 'projects', :action => 'build'
  end
  map.root     :controller => "projects"
  map.metrics  "/projects/:name/tmp/metric_fu/output/index.html", :controller => nil
  map.specs    "/projects/:name/doc/specs.html",                  :controller => nil
  map.features "/projects/:name/doc/features.html",               :controller => nil
  map.war      "/projects/:name/target/:name.war",                :controller => nil
end
