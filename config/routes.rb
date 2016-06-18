Rails.application.routes.draw do
  get 'pages/root'

  get "/get_angellist_listings", to: "pages#get_angellist_listings"
  get "/get_indeed_listings", to: "pages#get_indeed_listings"
  get "/get_stackoverflow_listings", to: "pages#get_stackoverflow_listings"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/", to: "pages#root"
  post "/update", to: "pages#update"
  post "/search", to: "pages#search"
  get "/category_toggler", to: "pages#category_toggler"
end
