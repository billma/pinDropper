PinDropper::Application.routes.draw do
  root :to => 'map#new'
  match "map/:id"=>"map#show"   
  match "/update"=>"map#update"
  match "/loadMarkers"=>"map#loadMarkers"
end
