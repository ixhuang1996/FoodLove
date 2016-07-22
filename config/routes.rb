Rails.application.routes.draw do

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to:	'sessions#destroy'

  get "/search", to: 'products#search'

  resources :users
  resources :farms do
    resources :products
      match 'products/all/edit' => 'products#edit_all', :as => :edit_all, :via => :get
      match 'products/all' => 'products#update_all', :as => :update_all, :via => :put
    get 'upload', :on => :member
  end
  resources :distributors do
    get 'printall', :on => :member
    get 'add_farm', :on => :member
    post 'new_farm', :on => :member
  end
  resources :buyers do
    get 'add_farm', :on => :member
    post 'new_farm', :on => :member
    delete 'remove_farm', :on => :member
    get 'add_dist', :on => :member
    post 'new_dist', :on => :member
    delete 'remove_dist', :on => :member
    resources :orders do
      get 'login_order', to: 'sessions#order_start'
      get 'logout_order', to: 'sessions#order_end'
      get 'add_product', :on => :member
      get 'print', :on => :member
      delete 'remove_product', :on => :member
      post 'place', :on => :member
    end
  end

  root 'users#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'

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