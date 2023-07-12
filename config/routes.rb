Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "pages#home"
  resources :drafts, param: :slug do
    member do
      post :generate
      post :start_next_selection
      patch :start
      get :invite
      post :invite, to: "drafts#create_invite"
      get :access
      post :access, to: "drafts#verify_and_join"
    end
  end
end
