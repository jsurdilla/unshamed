Rails.application.routes.draw do
  root 'home#index'

  mount_devise_token_auth_for 'User', at: '/auth', controllers: {
    token_validations: 'overrides/token_validations',
    confirmations: 'overrides/confirmations'
  }

  namespace :api do
    namespace :v1, defaults: { format: 'json' } do
      resource :me, controller: 'me' do
        member do
          get :timeline
          put :onboard
        end
      end

      resources :users do
        member do
          put :onboard
        end
        collection do
          get :check_username
          get :most_recent
        end

        delete 'friendship_requests' => 'friendship_requests#destroy'
        resources :friendship_requests

        delete 'friendships' => 'friendships#destroy'
      end

      resources :friends

      resources :resources

      resources :posts

      resources :comments

      resources :journal_entries

      post 'supports/toggle' => 'supports#toggle'

      resources :conversations do
        collection do
          get :inbox
          get :sentbox
          get :trash
        end

        member do
          post :reply
        end
      end

      resource :timeline
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
