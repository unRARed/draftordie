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
      post :join
      delete :leave
      patch :start
      patch :pause
      get :invite
      post :invite, to: "drafts#reate_invite"
      get :access
      post :access, to: "drafts#verify_access"
    end

    resources :selections, only: [:edit, :update]
    resources :pairings, only: [:destroy]
  end
end
