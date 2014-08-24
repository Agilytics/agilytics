Agilytics::Application.routes.draw do

  resources :sprints

  get 'api/sites', to: 'sites#index'
  get 'api/boards/velocities', to: 'boards#velocities'

  get 'api/sprints/forBoard', to: 'sprints#forBoard'
  get 'api/sprints/forBoardNotReleased', to: 'sprints#forBoardNotReleased'

  get 'api/boards', to: 'boards#index'
  get 'api/boards/:id/categories', to: 'boards#categories'
  get 'api/boards/:id/stats', to: 'boards#stats'
  get 'api/boards/:id/tags', to: 'boards#tags'
  post 'api/boards/updateBoards', to: 'boards#updateBoards'
  post '/api/boards/:id/setCategories', to: 'boards#set_categories'
  post '/api/boards/:id/deleteCategory', to: 'boards#delete_category'

  post 'api/boards/:id/update', to: 'boards#update'

  get 'api/releases', to: 'releases#index'
  post 'api/releases/delete', to: 'releases#delete'
  post 'api/releases/create', to: 'releases#create'
  post 'api/releases/update', to: 'releases#update'

  get 'import/quote'
  get 'import/metrics'
  get 'import/changes'
  get 'import/boards'
  get 'import/import'
  get 'import/grid'
  get 'import/gridChanges'
  get 'import/createMasterGrid'


  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  #root :to => 'import#metrics'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
