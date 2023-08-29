Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"

  if Rails.env.development?
    get :docs, to: "pages#docs"
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :drafts, param: :slug do
    member do
      get :board
      get :commish
      post :generate
      post :start_next_selection
      get :join
      post :join, to: "drafts#create_pairing"
      delete :leave
      delete "remove_user/:user_id",
        to: "drafts#remove_user", as: :remove_user
      patch :start
      patch :pause
      get :invite
      post :invite, to: "drafts#create_invite"
      get :access
      post :access, to: "drafts#verify_access"
      get :toggle_sound
      get :players
      get :order, to: "drafts#edit_order"
      patch :order, to: "drafts#update_order"
      patch :fill, to: "drafts#fill"
    end

    resources :selections, only: [:edit, :update] do
      collection do
        get :bulk_edit
      end

      member do
        get :player_data, to: "selections#edit_player_data"
        patch :player_data, to: "selections#update_player_data"
        get :commish_edit, to: "selections#commish_edit"
      end
    end

    resources :pairings, only: [:destroy]
  end
end
