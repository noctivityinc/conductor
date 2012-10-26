Conductor::Engine.routes.draw do
  match '/conductor', :to => "dashboard#index", :as => "conductor_dashboard"
  root :to => "dashboard#index"
end
