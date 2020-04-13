Rails.application.routes.draw do

	get 'welcome/index'
	root 'welcome#index'
	get '/insert_receipt_data' => 'welcome#insert_receipt_data', as: 'insert_receipt_data'
	get '/load_rakuten_order/:id' => 'welcome#load_rakuten_order', as: 'load_rakuten_order'
	get '/load_online_order/:id' => 'welcome#load_online_order', as: 'load_online_order'
	get '/update_rakuten_order/:id' => 'welcome#update_rakuten_order', as: 'update_rakuten_order'

	resources :frozen_oysters
	get '/insert_frozen_data' => 'frozen_oysters#insert_frozen_data', as: 'insert_frozen_data'

	resources :expiration_cards
	get 'expiration_cards/new/:product_name/:ingredient_source/:consumption_restrictions/:manufactuered_date/:expiration_date/:made_on/:shomiorhi', as: 'new', to: 'expiration_cards#new'

	resources :oyster_supplies
	get '/oyster_supplies/payment_pdf/:format/:start_date/:end_date/:location(.:format)', as: :payment_pdf, to: 'oyster_supplies#payment_pdf'
	get '/oyster_supplies/new_by/:supply_date(.:format)', as: :new_by, to: 'oyster_supplies#new_by'
	get '/oyster_supplies/supply_check/:id(.:format)', as: :supply_check, to: 'oyster_supplies#supply_check'
	get '/oyster_supplies/fetch_supplies/:start/:end(.:format)', as: :fetch_supplies, to: 'oyster_supplies#fetch_supplies'
	resources :suppliers
	devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
	get '/login', to: 'sessions#new'
	
	match '/users/approveUser',   to: 'users#approveUser',   via: 'get'
	match '/users/unapproveUser',   to: 'users#unapproveUser',   via: 'get'
	match 'users/:id' => 'users#destroy', :via => :delete, :as => :admin_destroy_user
	match 'users/:id' => 'users#show', via: 'get', as: :user
	resources :users
	
	resources :noshis do
		collection do
			delete 'destroy_multiple'
		end
	end
	get 'noshis/new/:ntype/:namae', as: :new_noshi_with_params, to: 'noshis#new'

	resources :categories do
		collection do
			delete 'destroy_multiple'
		end
	end
	
	resources :articles do
		resources :comments
		resources :categories
		collection do
			delete 'destroy_multiple'
		end
	end
	get '/fetch_articles' => 'articles#from_category', as: 'fetch_articles'

	resources :profits do
		resources :markets
		resources :products
		collection do
			get 'new_by_product_type'
			get 'new_tabs'
		end
	end
	get '/profits/:id/tab_edit' => 'profits#tab_edit', as: 'tab_edit'
	get '/fetch_market' => 'profits#fetch_market', as: 'fetch_market'
	patch 'profits/:id/autosave', as: :autosave_profit, to: 'profits#autosave'
	patch 'profits/:id/autosave_tab', as: :autosave_tab, to: 'profits#autosave_tab'
	post '/initital_save' => 'profits#initital_save', as: 'initital_save'
	patch 'profits/:id/tab_keisan' => 'profits#tab_keisan', as: 'tab_keisan'

	resources :products do
		resources :markets
		resources :materials
	end
	get '/product_pdf' => 'products#product_pdf', as: 'product_pdf'
	get '/fetch_products_by_type' => 'products#fetch_products_by_type', as: 'fetch_products_by_type'
	get '/insert_product_data' => 'products#insert_product_data', as: 'insert_product_data'
	
	resources :markets do
		resources :products
	end

	resources :materials do
		resources :products
	end
	post 'materials/:id(.:format)' => 'materials#update'
	get '/insert_material_data' => 'materials#insert_material_data', as: 'insert_material_data'

	resources :r_manifests
	get '/r_manifests/:id/pdf', as: :r_manifest_pdf, to: 'r_manifests#pdf'
	get '/r_manifests/:id/new_pdf', as: :r_manifest_new_pdf, to: 'r_manifests#new_pdf'
	get '/r_manifests/:id/seperated_pdf', as: :r_manifest_seperated_pdf, to: 'r_manifests#seperated_pdf'
	get '/r_manifests/:id/reciept/:order_id/:purchaser/:expense_name/:sales_date(.:format)', as: 'reciept', to: 'r_manifests#reciept'
	
	get '/manifests/csv' => 'manifests#csv', as: :csv
	get '/manifests/csv_result/(.:format)' => 'manifests#csv_result', as: :csv_result
	post '/manifests/csv_upload/(.:format)', as: :csv_upload, to: 'manifests#csv_upload'
	resources :manifests
	get '/manifests/:id/pdf', as: :manifest_pdf, to: 'manifests#pdf'
	get '/manifests/empty_manifest/:type(.:format)', as: :empty_manifest, to: 'manifests#empty_manifest'

	resources :restaurants

end

