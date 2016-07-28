Rails.application.routes.draw do
  get 'test/root'

  get 'pages/root'

  get "/get_indeed_listings", to: "pages#get_indeed_listings"
  get "/get_stackoverflow_listings", to: "pages#get_stackoverflow_listings"
  get "/get_remoteok_listings", to: "pages#get_remoteok_listings"
  get "/add_yaml_list", to: "pages#add_yaml_list"
  post "/save_yaml_list", to: "pages#save_yaml_list"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/", to: "pages#root"
  post "/update", to: "pages#update"
  post "/search", to: "pages#search"
  get "/category_toggler", to: "pages#category_toggler"
end
