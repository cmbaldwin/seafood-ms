Rails.application.routes.draw do

	# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

	# WELCOME/INDEX
	get 'welcome/index'
	root 'welcome#index'

	post '/shipping_data_csv' => 'welcome#shipping_data_csv', as: 'shipping_data_csv'
	get '/insert_receipt_data' => 'welcome#insert_receipt_data', as: 'insert_receipt_data'
	get '/load_rakuten_order/:id' => 'welcome#load_rakuten_order', as: 'load_rakuten_order'
	get '/load_online_order/:date' => 'welcome#load_online_orders', as: 'load_online_orders'
	get '/load_yahoo_orders/:date' => 'welcome#load_yahoo_orders', as: 'load_yahoo_orders'
	get '/load_infomart_orders/:date' => 'welcome#load_infomart_orders', as: 'load_infomart_orders'
	get '/update_rakuten_order/:id' => 'welcome#update_rakuten_order', as: 'update_rakuten_order'
	get '/insert_noshi_data/:namae/:ntype' => 'noshis#insert_noshi_data', as: 'insert_noshi_data'
		# charts
	get '/fetch_chart/:chart_params' => 'application#fetch_chart', as: 'fetch_chart'
	get '/profit_figures_chart' => 'welcome#profit_figures_chart', as: 'profit_figures_chart'
	get '/kilo_sales_estimate_chart' => 'welcome#kilo_sales_estimate_chart', as: 'kilo_sales_estimate_chart'
	get '/farmer_kilo_costs_chart' => 'welcome#farmer_kilo_costs_chart', as: 'farmer_kilo_costs_chart'
	get '/daily_volumes_chart' => 'welcome#daily_volumes_chart', as: 'daily_volumes_chart'
		# render_async
	get :noshi_modal, controller: :welcome
	get :daily_expiration_cards, controller: :welcome
	get :rakuten_orders, controller: :welcome
	get :receipt_partial, controller: :welcome
	get :front_infomart_orders, controller: :welcome
	get :infomart_shinki_modal, controller: :welcome
	get :front_online_orders, controller: :welcome
	get :online_orders_modal, controller: :welcome
	get :yahoo_orders_partial, controller: :welcome
	get :new_yahoo_orders_modal, controller: :welcome
	get :rakuten_shinki_modal, controller: :welcome
	get :frozen_data_modal, controller: :welcome
	get :charts_partial, controller: :welcome
	get :printables, controller: :welcome
	get :weather_partial, controller: :welcome
	get :user_control, controller: :welcome
	get :frozen_data, controller: :welcome

	# ANALYSIS
	get 'analysis' => 'analysis#index', as: 'analysis'
	get '/fetch_analysis' => 'analysis#fetch_analysis', as: 'fetch_analysis'

	# MESSAGES
	resources :messages, only: [:destroy]
	get '/messages/display_messages' => 'messages#display_messages', as: 'display_messages'
	get '/refresh_messages/' => 'messages#refresh', as: 'refresh_messages'
	get '/print_message' => 'messages#print_message', as: 'print_message'
	get '*model/print_message' => 'messages#print_model_message', as: 'print_model_message'
	post '/messages/set_dismissed/:id' => 'messages#set_dismissed', as: 'set_dismissed'
	post '/messages/clear_expired_messages' => 'messages#clear_expired_messages', as: 'clear_expired_messages'

	# FROZEN OYSTERS
	resources :frozen_oysters
	get '/insert_frozen_data' => 'frozen_oysters#insert_frozen_data', as: 'insert_frozen_data'

	# EXPIRATION CARDS
	resources :expiration_cards
	get 'expiration_cards/new/:product_name/:ingredient_source/:consumption_restrictions/:manufactuered_date/:expiration_date/:made_on/:shomiorhi', as: 'new', to: 'expiration_cards#new'

	# OYSTER SUPPLIES
	resources :oyster_supplies
	get '/oyster_supplies/payment_pdf/:export_format/:start_date/:end_date/:location', as: :payment_pdf, to: 'oyster_supplies#payment_pdf'
	get '/oyster_supplies/new_by/:supply_date(.:format)', as: :new_by, to: 'oyster_supplies#new_by'
	get '/oyster_supplies/supply_check/:id(.:format)', as: :supply_check, to: 'oyster_supplies#supply_check'
	get '/oyster_supplies/fetch_supplies/:start/:end(.:format)', as: :fetch_supplies, to: 'oyster_supplies#fetch_supplies'
	get '/oyster_supplies/fetch_invoice/:id(.:format)', as: 'fetch_invoice', to: 'oyster_supplies#fetch_invoice'
	get '/oyster_supplies/tippy_stats/:id/:stat', as: 'tippy_supply_stats', to: 'oyster_supplies#tippy_stats'
	get '/oyster_supplies/supply_action_nav/:start_date/:end_date', to: 'oyster_supplies#supply_action_nav'
	get '/oyster_supplies/new_invoice/:start_date/:end_date(.:format)', as: 'new_invoice', to: 'oyster_supplies#new_invoice'
	get '/oyster_supplies/supply_invoice_actions/:start_date/:end_date', as: 'supply_invoice_actions', to: 'oyster_supplies#supply_invoice_actions'
	get '/oyster_supplies/supply_price_actions/:start_date/:end_date', as: 'supply_price_actions', to: 'oyster_supplies#supply_price_actions'
	get '/oyster_supplies/supply_stats_partial/:start_date/:end_date', as: 'supply_stats_partial', to: 'oyster_supplies#supply_stats'
	post '/oyster_supplies/set_prices/:start_date/:end_date/', as: 'set_prices', to: 'oyster_supplies#set_prices'

	# OYSTER INVOICES
	resources :oyster_invoices
	get '/oyster_invoices/search/:id(.:format)', as: :oyster_invoice_search, to: 'oyster_invoices#index'
	get '/oyster_invoices/create/:start_date/:end_date(.:format)', as: :create, to: 'oyster_invoices#create'

	# SUPPLIERS
	resources :suppliers
	devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
	get '/login', to: 'sessions#new'

	# USERS
	match '/users/approveUser',   to: 'users#approveUser',   via: 'get'
	match '/users/unapproveUser',   to: 'users#unapproveUser',   via: 'get'
	match 'users/:id' => 'users#destroy', :via => :delete, :as => :admin_destroy_user
	match 'users/:id' => 'users#show', via: 'get', as: :user
	resources :users
	if defined?(Sidekiq::Web)
		authenticate :user do
			mount Sidekiq::Web => '/sidekiq'
		end
	end

	# NOSHIS
	resources :noshis do
		collection do
			delete 'destroy_multiple'
		end
	end
	get 'noshis/new/:ntype/:namae', as: :new_noshi_with_params, to: 'noshis#new'

	# PROFITS
	resources :profits do
		resources :markets
		resources :products
		collection do
			get 'new_by_product_type'
			get 'new_tabs'
		end
	end
	get 'profits/new/:sales_date' => 'profits#new_by_date', as: 'new_by_date'
	get '/profits/:id/tab_edit' => 'profits#tab_edit', as: 'tab_edit'
	get '/fetch_market' => 'profits#fetch_market', as: 'fetch_market'
	get '/profits/:id/next_market/:mjsnumber' => 'profits#next_market', as: 'next_market'
	get '/profits/:id/update_completion' => 'profits#update_completion', as: 'update_completion'
	patch 'profits/:id/autosave', as: :autosave_profit, to: 'profits#autosave'
	patch 'profits/:id/autosave_tab', as: :autosave_tab, to: 'profits#autosave_tab'
	patch 'profits/:id/tab_keisan' => 'profits#tab_keisan', as: 'tab_keisan'
	get 'profits/:id/fetch_volumes' => 'profits#fetch_volumes', as: 'fetch_volumes'

	get 'products/associations' => 'products#associations', as: 'associations'
	post 'products/set_associations' => 'products#set_associations', as: 'set_associations'
	post 'products/reset_associations' => 'products#reset_associations', as: 'reset_associations'
	get 'products/insert_products_by_type/:type_id' => 'products#copy_product_data', as: 'copy_product_data'
	resources :products do
		resources :markets
		resources :materials
	end
	get '/product_pdf' => 'products#product_pdf', as: 'product_pdf'
	get '/fetch_products_by_type' => 'products#fetch_products_by_type', as: 'fetch_products_by_type'
	get '/insert_product_data' => 'products#insert_product_data', as: 'insert_product_data'
	get '/insert_select_products_by_type/:type_id' => 'products#insert_select_products_by_type', as: 'insert_select_products_by_type'
	get '/insert_product_selected_button/:product_id' => 'products#insert_product_selected_button', as: 'insert_product_selected_button'
	# MARKETS
	resources :markets do
		resources :products
	end

	# MATERIALS
	resources :materials do
		resources :products
	end
	post 'materials/:id(.:format)' => 'materials#update'
	get '/insert_material_data' => 'materials#insert_material_data', as: 'insert_material_data'

	# RAKUTEN "MANIFEST"
	resources :r_manifests
	get '/r_manifests/:id/pdf', as: :r_manifest_pdf, to: 'r_manifests#pdf'
	get '/r_manifests/generate_pdf/:id/:seperated/:include_yahoo', as: :generate_rakuten_pdf, to: 'r_manifests#generate_pdf'
	get '/reciept/(.:format)', as: 'reciept', to: 'r_manifests#reciept'

	# INFOMART
	resources :infomart_orders, only: [:index]
	get '/fetch_infomart_list/:date', as: :fetch_infomart_list, to: 'infomart_orders#fetch_infomart_list'
	get 'refresh_infomart', as: :refresh_infomart, to: 'infomart_orders#refresh'
	get 'infomart_csv/:ship_date', as: :infomart_csv, to: 'infomart_orders#infomart_csv', defaults: { format: :csv }
	get 'infomart_shipping_list/:ship_date/:include_online', as: :infomart_shipping_list, to: 'infomart_orders#infomart_shipping_list'

	# YAHOO ORDERS
	resources :yahoo_orders, only: [:index]
	get 'yahoo', as: :yahoo_response_auth_code, to: 'yahoo_orders#yahoo_response_auth_code'
	get '/fetch_yahoo_list/:date', as: :fetch_yahoo_list, to: 'yahoo_orders#fetch_yahoo_list'
	get 'refresh_yahoo', as: :refresh_yahoo, to: 'yahoo_orders#refresh'
	get 'yahoo_spreadsheet/:ship_date', as: :yahoo_spreadsheet, to: 'yahoo_orders#yahoo_spreadsheet', defaults: { format: :xls }
	get 'yahoo_csv/:ship_date', as: :yahoo_csv, to: 'yahoo_orders#yahoo_csv', defaults: { format: :csv }
	get 'yahoo_shipping_list/:ship_date', as: :yahoo_shipping_list, to: 'yahoo_orders#yahoo_shipping_list'

	# FUNABIKI.INFO ORDERS
	resources :online_orders, only: [:index]
	get '/fetch_online_orders_list/:date', as: :fetch_online_orders_list, to: 'online_orders#fetch_online_orders_list'
	get 'refresh_online_orders', as: :refresh_online_orders, to: 'online_orders#refresh'
	get 'online_orders_csv/:ship_date', as: :online_orders_csv, to: 'online_orders#online_orders_csv', defaults: { format: :csv }
	get 'online_orders_shipping_list/:ship_date', as: :online_orders_shipping_list, to: 'online_orders#online_orders_shipping_list'

	# (OLD) MANIFEST FORMAT FOR INFOMART AND WOOCOMMERCE
	get '/manifests/csv' => 'manifests#csv', as: :csv
	get '/manifests/csv_result/(.:format)' => 'manifests#csv_result', as: :csv_result
	post '/manifests/csv_upload/(.:format)', as: :csv_upload, to: 'manifests#csv_upload'
	resources :manifests
	get '/manifests/:id/pdf', as: :manifest_pdf, to: 'manifests#pdf'
	get '/manifests/empty_manifest/:type(.:format)', as: :empty_manifest, to: 'manifests#empty_manifest'

	resources :restaurants
	get '/insert_restaurant_data' => 'restaurants#insert_restaurant_data', as: 'insert_restaurant_data'

	# (OLD) ARTICLES (CREATED WHEN FIRST LEARNING RAILS, MAY STILL BE USEFUL)
	resources :articles do
		resources :comments
		resources :categories
		collection do
			delete 'destroy_multiple'
		end
	end
	get '/fetch_articles' => 'articles#from_category', as: 'fetch_articles'

	resources :categories do
		collection do
			delete 'destroy_multiple'
		end
	end

end
