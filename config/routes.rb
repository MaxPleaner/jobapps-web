Rails.application.routes.draw do
  get 'pages/root'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/", to: "pages#root"
  post "/update", to: "pages#update"
  post "/search", to: "pages#search"
  get "/category_toggler", to: "pages#category_toggler"
end
