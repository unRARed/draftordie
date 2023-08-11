Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"

  devise_for :users

  resources :drafts, param: :slug do
    member do
      get :board
      get :commish
      post :generate
      post :start_next_selection
      get :join
      post :join, to: "drafts#create_pairing"
      delete :leave
      patch :start
      patch :pause
      get :invite
      post :invite, to: "drafts#create_invite"
      get :access
      post :access, to: "drafts#verify_access"
      get :toggle_sound
    end

    resources :selections, only: [:edit, :update]
    resources :pairings, only: [:destroy]
  end
end
