Bioturk::Application.routes.draw do

  resources :tasks

  resources :task_prototypes

  get "metacols/draw"
   match 'viewer',        to: 'metacols#viewer'

  resources :metacols do
      get 'arguments', on: :new
      get 'narguments', on: :new
      get 'launch', on: :new
      get 'stop'
  end 

  resources :groups

  resources :collections do
    member do
      get 'associate'
      get 'dissociate'
      get 'newitem'
    end
  end

  resources :cart_items, only: [ :index, :new, :destroy ]
  resources :samples
  resources :sample_types

  match '/spreadsheet', to: 'samples#spreadsheet'
  match '/process_spreadsheet', to: 'samples#process_spreadsheet'

  match "interpreter/open_local_file", to: 'interpreter#open_local_file', via: [:post]

  get "interpreter/arguments"
  get "interpreter/narguments"
  get "interpreter/submit"
  get "interpreter/current"
  get "interpreter/advance"
  get "interpreter/abort"
  get "interpreter/cancel"
  get "interpreter/error"
  get "interpreter/release"
  get "interpreter/edit"
  get "interpreter/resubmit"

  get "stats/jobs"
  get "stats/users"
  get "stats/user_activity"
  get "stats/protocols"
  get "stats/outcomes"
  get "stats/samples"
  get "stats/objects"
  get "stats/processes"
  get "stats/empty"
  get "stats/timing"

  get "jobs/index"
  get "jobs/summary"

  get "liaison/info"
  get "liaison/take"
  get "liaison/release"
  get "liaison/produce"

  get "protocol_tree/file"
  get "protocol_tree/recent"

  get "repo/list"
  get "repo/get"
  get "repo/pull"

  resources :items

  match "project", to: 'samples#project'

  resources :object_types do 
    resources :items do
      collection do
        get 'update'
      end
    end
  end

  root to: 'static_pages#home'

  match '/',        to: 'static_pages#home'
  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/status',  to: 'static_pages#status'
  match '/analytics',  to: 'static_pages#analytics'
  match '/jobchart', to: 'static_pages#jobchart'
  match '/changes', to: 'static_pages#changes'
  match '/location', to: 'static_pages#location'
  match '/freezer', to: 'static_pages#freezer'

  match '/search', to: 'search#search'
  
  match '/inventory_stats', to: 'static_pages#inventory_stats'
  match '/inventory_critical', to: 'static_pages#inventory_critical'
  match '/protocol_usage', to: 'static_pages#protocol_usage'

  get '/production_interface', to: 'object_types#production_interface'
  get '/delete_inventory', to: 'object_types#delete_inventory'
  get '/copy_inventory_from_production', to: 'object_types#copy_inventory_from_production'
  get '/copy_users_from_production', to: 'users#copy_users_from_production'
  get '/copy_tasks_from_production', to: 'tasks#copy_tasks_from_production'

  match '/signup', to: 'users#new'
  match '/password', to: 'users#password'

  resources :users do 
    get 'change_password'
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :jobs, only: [:index, :destroy, :show]
  resources :logs, only: [:index, :show]

  match '/item', to: 'items#update'

  get "oyster/ping"
  get "oyster/submit"
  get "oyster/status"
  get "oyster/log"
  get "oyster/info"
  get "oyster/items"

end
