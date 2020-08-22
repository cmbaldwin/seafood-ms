namespace :stats do

	desc "Market and Product Stats"
	task :refresh_stats => :environment do

		puts "Calculating Market and Product stats"
		puts 'First checking old Frozen Oyster data for products without entries'
		FrozenOyster.all.each do |fro|
			fro.fix_empty_products
		end

		markets = Market.all
		len = markets.length.to_s
		puts 'Peforming Market stat calculations. Total: ' + len
		markets.each_with_index do |market, i|
			if market.updated_at < Date.today
				puts "Market ID##{market.id} (#{i+1} of #{len})"
				market.do_stats
				puts "success."
			end
		end

		products = Product.all
		len = products.length.to_s
		products.each_with_index do |product, i|
			if product.updated_at < Date.today
				puts "Product ID##{product.id} (#{i+1} of #{len})"
				product.do_stats
			end
		end

	end
end

namespace :restaurants do

	desc "Scrape Infomart restaurants"
	task :scrape_infomart_for_restaurants => :environment do
		require 'mechanize'

		puts "Scraping Infomart for restaurants"
		agent = Mechanize.new
		# Set scrape date (unused)
		# scrape_date = DateTime.now
		#Init browsing agent
		#go to the login page with endpoint of customers page
		page = agent.get('https://www2.infomart.co.jp/trade/my_catalog_trade.page?2')
		login_form = page.form('form01')
		#login
		login_form.UID = ENV['INFOMART_LOGIN']
		login_form.PWD = ENV['INFOMART_PASS']
		page = agent.submit(login_form)
		#we're in setup a hash to temporarily store information and let's iterate
		restaurant_ids = Hash.new
		# Iterating pages won't work with mechanize's limited JS ability
		# page_number = page.search('#id1 span.num')
		puts 'This only works for the first page (because of JS issues), scraping that page now'
		restaurant_links = page.search('#dataList tbody.slip-summary-a')
		puts 'Found ' + restaurant_links.length.to_s + ' potential restaurants on this page'
		restaurant_links.each_with_index do |row, i|
			puts 'Recording link #' + (i + 1).to_s + ' of ' + restaurant_links.length.to_s
			restaurant_name = row.search('tr')[0].search('td')[2].search('a').text.to_s
			mjs_id = row.search('tr')[0].search('td')[2].search('a').to_s[/(?<=mcd\=).*(?=')/]
			restaurant_ids[restaurant_name] = mjs_id
		end
		puts 'Loading each restaurant page to gather data'
		restaurants = Hash.new
		restaurant_ids.each do |restaurant, id|
			puts 'Loading ' + restaurant
			restaurants[restaurant] = Hash.new
			restaurants[restaurant][:infomart_id] = id
			page = agent.get('https://www2.infomart.co.jp/seller/search/company_detail.page?19&mcd=' + id)
			if login_form = page.form('form01')
				#login
				login_form.UID = ENV['INFOMART_LOGIN']
				login_form.PWD = ENV['INFOMART_PASS']
				page = agent.submit(login_form)
			end
			info_blocks = page.search('form .clr .bb-dot-td-div')
			info_blocks.each_with_index do |block, i|
				if (i % 2 == 0)
					@odd_block = block.text.to_s
					restaurants[restaurant][@odd_block] = info_blocks[i + 1].text.to_s
				end
			end
		end
		puts 'Finished loading, returning hashed data'
		puts 'Creating new restaurants'
		i = 0
		restaurants.each do |restaurant_name, restaurant_hash|
			if !Restaurant.find_by(namae: restaurant_name)
				i += 1
				puts "New restaurant found: " + restaurant_name
				new_restaurant = Restaurant.new(namae: restaurant_name, link: restaurant_hash[:infomart_id], company: restaurant_hash["本部"], address: restaurant_hash["住所"], products: Hash.new, stats: Hash.new)
				new_restaurant.save
				puts "Saved @ " + new_restaurant.to_s
			else
				"Found existing record: " + Restaurant.find_by(namae: restaurant_name).to_s
			end
		end
	end

	desc "Set existing Manifests with associated Restaurant"
	task :set_manifest_restaurants => :environment do
		include ActionView::Helpers::ManifestsHelper

		puts "Setting existing Manifests with associated Restaurant"
		Manifest.all.each_with_index do |manifest, i|
			@manifest = manifest
			new_hash = Hash.new
			puts "Checking Manifest ID#{manifest.id }"
			manifest.infomart_orders.each_with_index do |(type, type_hash), oi|
				oi == 0 ? manifest.restaurants.destroy_all : ()
				!new_hash[type] ? new_hash[type] = Hash.new : ()
				type_hash.each do |order_number, order_hash|
					if same_day(order_hash) || two_days(order_hash) || fresh_order(order_hash)
						if !order_hash[:restaurant_id] || Restaurant.exists?(order_hash[:restaurant_id])
							!new_hash[type][order_number] ? new_hash[type][order_number] = order_hash : ()
							restaurant = Restaurant.find_by(namae: order_hash[:client])
							if !restaurant.nil?
								new_hash[type][order_number][:restaurant_id] = restaurant.id
								manifest.restaurants << restaurant
								print "Restaurant found, ID#{restaurant.id}, "
							else
								puts "Restaurant #{order_hash[:client]} not found, trying to fix... "
								restaurant = Restaurant.find_by(namae: order_hash[:client].gsub("保存",""))
								if !restaurant.nil?
									puts "Error, 保存 was in name."
									new_hash[type][order_number][:restaurant_id] = restaurant.id
									manifest.restaurants << restaurant
									puts "Restaurant #{order_hash[:client]} not found, trying to fix..."
								else
									puts "Could be retired restaurant, creating without link"
									restaurant = Restaurant.new(namae: order_hash[:client], link: order_hash[:client])
									if restaurant.save
										puts "Restaurant created, ID#{restaurant.id}"
										new_hash[type][order_number][:restaurant_id] = restaurant.id
										manifest.restaurants << restaurant
									else
										p restaurant.errors
									end
								end
							end
						end
					end
				end
				manifest.infomart_orders = new_hash
				manifest.save
				if Manifest.all.length - 1 == i 
					print "Finished."
				else
					print "Next."
				end
			end
		end
	end

	desc "Search existing Manifests for products to be associated with Restaurants"
	task :set_restaurant_products_from_manifests => :environment do
		puts "Searching existing Manifests for products to be associated with Restaurants"
		task_length = Manifest.all.length + 1
		Manifest.all.each_with_index do |manifest, i|
			puts "Checking Manifest ID#{manifest.id} (#{i + 1}/#{task_length})"
			manifest.infomart_orders.each do |type, type_hash|
				type_hash.each do |order_number, order_hash|
					if order_hash[:items]
						if Restaurant.exists?(order_hash[:restaurant_id])
							restaurant = Restaurant.find(order_hash[:restaurant_id])
							restaurant.products.nil? ? restaurant.products = Hash.new : ()
							restaurant.products[type].nil? ? restaurant.products[type] = Hash.new : ()
							puts "Editing #{restaurant.namae}"
							order_hash[:items].each do |item, item_hash|
								item_name = item_hash[:item_name].match(/(?!\r).*/).to_s.chomp.gsub('/ｃｓ\r', '')
								pi = 0
								if restaurant.products[type][item_name].nil?
									restaurant.products[type][item_name] = 0
									puts "Added #{item_name}"
									pi += 1
								end
								(pi > 0) ? (restaurant.save && (puts 'Saved ' + restaurant.namae + 'with ' + pi.to_s + 'additonal products')) : (puts 'No change')
							end
						else
							puts "Restaurant called \"#{order_hash[:client]}\" with ID#{order_hash[:restaurant_id]} could not be found..."
						end
					end
				end
			end
		end
	end

	desc "Calculate totals and other stats for each Restaurant"
	task :calculate_restaurant_stats => :environment do
		puts "Calculating totals and other stats for each Restaurant"
		allRestaurants = Restaurant.all
		allRestaurants.each_with_index do |r, i|
			puts i.to_s + ' of ' + allRestaurants.length.to_s
			puts 'Calculating stats for ' + r.namae + ' (ID#' + r.id.to_s + ')'
			r.do_stats
			puts 'finished'
		end
	end

	task :runall => [:scrape_infomart_for_restaurants, :set_manifest_restaurants, :set_restaurant_products_from_manifests, :calculate_restaurant_stats] do
		puts "All tasks completed"
	end

end

namespace :averages do

	desc "Calculate average prices for Products from all existing Profit records"
	task :product_averages => :environment do

		# Set up the arrays for each price for each product
		puts 'Setting up variables'
		product_prices = Hash.new
		Product.all.each do |product|
			product_prices[product.id] = Array.new
		end

		puts 'Iterating through Profits'
		# Iterate through each Profit adding it to the array
		Profit.all.each_with_index do |profit, i|
			puts 'Sarching Profit#' + (i + 1).to_s + ' of ' + Profit.all.length.to_s
			profit.figures.each do |type_id, type_hash|
				type_hash.each do |product_id, product_hash|
					product_hash.each do |market_id, values_hash|
						if values_hash[:order_count] > 0
							if values_hash[:unit_price] > 0
								product_prices[product_id] << values_hash[:unit_price]
							end
						end
					end
				end
			end
		end

		puts 'Finished. Setting each Product\'s average price.'
		# Set the average price for each Product
		product_prices.each do |product_id, price_array|
			product = Product.find(product_id)
			if !price_array.empty?
				product.average_price = (price_array.sum / price_array.length)
			else
				product.average_price = 0
			end
			product.save
		end
		puts 'Task complete.'

	end

end

namespace :daily_shell_cards do

	desc "Create today's shell cards and delete all expiration cards with manufacturing dates from yesterday"
	task :do_prep => :environment do

		today = Date.today
		def nengapi_maker(date, adjust)
			(date + adjust).strftime('%Y年%m月%d日')
		end
		
		#Destroy cards from prior day
		ExpirationCard.where(manufactuered_date: [nengapi_maker(today, -1), '']).destroy_all

		#Sakoshi Today + 4
		puts 'Create Sakoshi Today + 4'
		@sakoshi_expiration_today = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県坂越海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 0), expiration_date: nengapi_maker(today, 4), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@sakoshi_expiration_today.create_pdf
		@sakoshi_expiration_today.save
		puts 'Created:'
		puts @sakoshi_expiration_today.to_s
		puts '------------------------'
		#Sakoshi Today + 5
		puts 'Create Sakoshi Today + 5'
		@sakoshi_expiration_today_five = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県坂越海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 0), expiration_date: nengapi_maker(today, 5), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@sakoshi_expiration_today_five.create_pdf
		@sakoshi_expiration_today_five.save
		puts 'Created:'
		puts @sakoshi_expiration_today_five.to_s
		puts '------------------------'
		#Sakoshi Tomorrow + 4
		puts 'Create Sakoshi Tomorrow + 4'
		@sakoshi_expiration_tomorrow = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県坂越海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 1), expiration_date: nengapi_maker(today, 5), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@sakoshi_expiration_tomorrow.create_pdf
		@sakoshi_expiration_tomorrow.save
		puts 'Created:'
		puts @sakoshi_expiration_tomorrow.to_s
		puts '------------------------'
		#Sakoshi Tomorrow + 5
		puts 'Create Sakoshi Tomorrow + 5'
		@sakoshi_expiration_tomorrow_five = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県坂越海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 1), expiration_date: nengapi_maker(today, 6), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@sakoshi_expiration_tomorrow_five.create_pdf
		@sakoshi_expiration_tomorrow_five.save
		puts 'Created:'
		puts @sakoshi_expiration_tomorrow_five.to_s
		puts '------------------------'
		#Sakoshi Today + 5 (No Manufactured By Date)
		puts 'Create Sakoshi Today + 5 (No Manufactured By Date)'
		@sakoshi_expiration_today_five_expo = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県坂越海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 0), expiration_date: nengapi_maker(today, 5), storage_recommendation: "要冷蔵　0℃～10℃", made_on: false, shomiorhi: true)
		@sakoshi_expiration_today_five_expo.create_pdf
		@sakoshi_expiration_today_five_expo.save
		puts 'Created:'
		puts @sakoshi_expiration_today_five_expo.to_s
		puts '------------------------'
		#Sakoshi Muji
		puts 'Create Sakoshi Muji'
		@sakoshi_expiration_muji = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県坂越海域", consumption_restrictions: "生食用", manufactuered_date: '', expiration_date: '', storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@sakoshi_expiration_muji.create_pdf
		@sakoshi_expiration_muji.save
		puts 'Created:'
		puts @sakoshi_expiration_muji.to_s
		puts '------------------------'

		#Aioi Today + 4
		puts 'Create Aioi Today + 4'
		@aioi_expiration_today = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県相生海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 0), expiration_date: nengapi_maker(today, 4), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@aioi_expiration_today.create_pdf
		@aioi_expiration_today.save
		puts 'Created:'
		puts @aioi_expiration_today.to_s
		puts '------------------------'
		#Aioi Today + 5
		puts 'Create Aioi Today + 5'
		@aioi_expiration_today_five = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県相生海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 0), expiration_date: nengapi_maker(today, 5), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@aioi_expiration_today_five.create_pdf
		@aioi_expiration_today_five.save
		puts 'Created:'
		puts @aioi_expiration_today_five.to_s
		puts '------------------------'
		#Aioi Tomorrow + 4
		puts 'Create Aioi Tomorrow + 4'
		@aioi_expiration_tomorrow = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県相生海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 1), expiration_date: nengapi_maker(today, 5), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@aioi_expiration_tomorrow.create_pdf
		@aioi_expiration_tomorrow.save
		puts 'Created:'
		puts @aioi_expiration_tomorrow.to_s
		puts '------------------------'
		#Aioi Tomorrow + 5
		puts 'Create Aioi Tomorrow + 5'
		@aioi_expiration_tomorrow_five = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県相生海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 1), expiration_date: nengapi_maker(today, 6), storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@aioi_expiration_tomorrow_five.create_pdf
		@aioi_expiration_tomorrow_five.save
		puts 'Created:'
		puts @aioi_expiration_tomorrow_five.to_s
		puts '------------------------'
		#Aioi Today + 5 (No Manufactured By Date)
		puts 'Create Aioi Today + 5 (No Manufactured By Date)'
		@aioi_expiration_today_five_expo = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県相生海域", consumption_restrictions: "生食用", manufactuered_date: nengapi_maker(today, 0), expiration_date: nengapi_maker(today, 5), storage_recommendation: "要冷蔵　0℃～10℃", made_on: false, shomiorhi: true)
		@aioi_expiration_today_five_expo.create_pdf
		@aioi_expiration_today_five_expo.save
		puts 'Created:'
		puts @aioi_expiration_today_five_expo.to_s
		puts '------------------------'
		#Sakoshi Muji
		puts 'Create Aioi Muji'
		@aioi_expiration_muji = ExpirationCard.new(product_name: "殻付き かき", manufacturer_address: "兵庫県赤穂市中広1576-11", manufacturer: "株式会社 船曳商店", ingredient_source: "兵庫県相生海域", consumption_restrictions: "生食用", manufactuered_date: '', expiration_date: '', storage_recommendation: "要冷蔵　0℃～10℃", made_on: true, shomiorhi: true)
		@aioi_expiration_muji.create_pdf
		@aioi_expiration_muji.save
		puts 'Created:'
		puts @aioi_expiration_muji.to_s
		puts '------------------------'

	end

end

namespace :pull_order_data do

	desc "Pull and replace data today and tomorrow's Infomart and Woocommerce order data"
	task :pull_tsuhan => :environment do

		def get_woocommerce_orders(sales_date)
			require "json"

			wc_orders_json = JSON.load(open('https://www.funabiki.info/wp-json/wc/v3/orders?per_page=100&search=' + (DateTime.strptime(sales_date, '%Y年%m月%d日')).strftime("%Y-%m-%d") + '&consumer_key=' + ENV['WOOCOMMERCE_CONSUMER_KEY'] + '&consumer_secret=' + ENV['WOOCOMMERCE_CONSUMER_SECRET']))

			#iterates through each order and seperates items into their respective type (given a type)
			def fill_wc_hash(wc_orders, order, item, type)

				#iterates through the metadata and sets JSON arrayed k/v to hashed k/v
				def set_key_from_meta(wc_orders, order, type, meta_key, new_key)
					(order['meta_data'].select{|array| array["key"] == meta_key }).each do |k, v|
						wc_orders[type.to_sym][order["id"]][new_key.to_sym] = k["value"]
					end
				end
				#make the hash unless it's already there
				if !wc_orders[type.to_sym][order["id"]].is_a?(Hash) then wc_orders[type.to_sym][order["id"]] = Hash.new end

				#basic data set
				wc_orders[type.to_sym][order["id"]][:url] = 'https://funabiki.info/wp-admin/post.php?post=' + order["id"].to_s + '&action=edit'
				wc_orders[type.to_sym][order["id"]][:sender] = order['billing']
				wc_orders[type.to_sym][order["id"]][:recipent] = order['shipping']
				wc_orders[type.to_sym][order["id"]][:items] = order['line_items']
				#set from meta data
				set_key_from_meta(wc_orders, order, type, 'ywot_pick_up_date', 'shipping_date')
				set_key_from_meta(wc_orders, order, type, 'wc4jp-delivery-date', 'arrival_date')
				set_key_from_meta(wc_orders, order, type, 'ywot_tracking_code', 'tracking')
				set_key_from_meta(wc_orders, order, type, 'wc4jp-delivery-time-zone', 'arrival_time')
				set_key_from_meta(wc_orders, order, type, '熨斗タイプ', 'noshi')
				#raw data from JSON
				wc_orders[type.to_sym][order["id"]][:raw_data] = order

			end

			wc_orders = Hash.new
			wc_orders[:raw] = Hash.new
			wc_orders[:frozen] = Hash.new
			wc_orders_json.each do |order|
				order["line_items"].each do |item|
					if item["name"].include?('冷凍')
						type = "frozen"
						fill_wc_hash(wc_orders, order, item, type)
					else
						wc_orders[:raw]
						type ="raw"
						fill_wc_hash(wc_orders, order, item, type)
					end
				end
			end
			wc_orders
		end
		def get_infomart(sales_date)
			require 'mechanize'

			agent = Mechanize.new
			#today's date 
			scrape_date = DateTime.strptime(sales_date, '%Y年%m月%d日')
			start_date = (scrape_date + 1).strftime("%Y/%m/%d")
			end_date = (scrape_date + 2).strftime("%Y/%m/%d")
			#go to the page to scrape
			page = agent.get('https://www2.infomart.co.jp/employment/shipping_list_window.page?6&st=0&parent=1&selbuy=0&op=00&f_date=' + start_date + '&t_date=' + end_date + '&stmnm&stmtel&HTradeState&resend&membersel=0&mcd_child&membernm&pdate=2&Infl=TC&TCalTradeState=0&TCalTradeState_2=0&TCalTradeState_3=0&TCalTradeState_4=0&TCalTradeState_5=0&TCalTradeState_6=0&TCalTradeState_7=1&TransitionPage_Cal=1&LeaveCond=1&perusal=0&cwflg=1')
			login_form = page.form('form01')
			#login
			login_form.UID = ENV['INFOMART_LOGIN']
			login_form.PWD = ENV['INFOMART_PASS']
			page = agent.submit(login_form)
			# we're in, set up the hashes
			orders = Hash.new
			orders[:raw] = Hash.new
			orders[:frozen] = Hash.new
			#find the order rows
			page.search('tbody.slip-summary-a').each do |order|
				#get the number of row so we can find how many of them are item rows
				row_count = order.search('tr').length
				#find the order number
				order_number = order.search('tr')[0].search('td')[1].text.to_s.to_sym
				backend_order_id = order.search('tr')[0].search('td')[6].to_s[/(?<=mfOpenTradeDetail\(')\d.*(?=',)/]
				#find client and arrival
				client = order.search('tr')[0].search('td')[4].text.to_s
				arrival = order.search('tr')[1].search('td')[0].text.to_s
				#iterate through the third to whatever rows, excluding the last (which is a spacer)
				#set up a hash for ordered items and input this as we go
				item_number = 0
				(row_count - 3).times do |i|
					item_number += 1
					item_row = order.search('tr')[(2 + i)]
					if !item_row.search('td')[1].nil? then item_name = item_row.search('td')[1].text.to_s end
					if !item_row.search('td')[4].nil? then item_count = item_row.search('td')[4].text.to_s end
					#check that we're not just adding a box or shipping costs
					if !item_name.nil?
						if item_name.match(/送料/).nil? && item_name.match(/箱代/).nil?
							#check if it's frozen
							if !item_name.match(/冷凍/).nil? or !item_name.match(/デカプリオイスター/).nil? or !item_name.match(/プロトン/).nil?
								#make the hash for the order if it's not there
								if !orders[:frozen][order_number].is_a?(Hash) then orders[:frozen][order_number] = Hash.new end
									orders[:frozen][order_number][:backend_id] = backend_order_id
									orders[:frozen][order_number][:client] = client
									orders[:frozen][order_number][:arrival] = arrival
									#make the order items hash if it it's not there
									if !orders[:frozen][order_number][:items].is_a?(Hash) then orders[:frozen][order_number][:items] = Hash.new end
										orders[:frozen][order_number][:items][item_number] = Hash.new
												orders[:frozen][order_number][:items][item_number][:item_name] = item_name
												orders[:frozen][order_number][:items][item_number][:item_count] = item_count
							#if it's not frozen it must be raw
							else
								#make the hash for the order if it's not there
								if !orders[:raw][order_number].is_a?(Hash) then orders[:raw][order_number] = Hash.new end
									# fill it in
									orders[:raw][order_number][:backend_id] = backend_order_id
									orders[:raw][order_number][:client] = client
									orders[:raw][order_number][:arrival] = arrival
									#make the order items hash if it it's not there
									if !orders[:raw][order_number][:items].is_a?(Hash) then orders[:raw][order_number][:items] = Hash.new end
										#fill it in
										if item_name.include?('坂越バラ牡蠣')
											bara_item_number = (row_count - 2)
											orders[:raw][order_number][:items][bara_item_number] = Hash.new
												orders[:raw][order_number][:items][bara_item_number][:item_name] = item_name
												orders[:raw][order_number][:items][bara_item_number][:item_count] = item_count
										else
											orders[:raw][order_number][:items][item_number] = Hash.new
												orders[:raw][order_number][:items][item_number][:item_name] = item_name
												orders[:raw][order_number][:items][item_number][:item_count] = item_count
										end
							end
						end
					end
				end
			end
			orders
		end

		puts "Scraping Infomart and pulling Funabiki.info's API Data..."
		#Infomart and Woocommerce
		manifest_today = Manifest.new(:sales_date => Date.today.strftime('%Y年%m月%d日'))
		manifest_today.infomart_orders = get_infomart(manifest_today.sales_date)
		puts "Updated today's Infomart orders"
		manifest_today.online_shop_orders = get_woocommerce_orders(manifest_today.sales_date)
		puts "Updated today's Woocommerce orders"
		manifest_today.save
		manifest_tomorrow = Manifest.new(:sales_date => Date.tomorrow.strftime('%Y年%m月%d日'))
		manifest_tomorrow.infomart_orders = get_infomart(manifest_tomorrow.sales_date)
		puts "Updated tomorrow's Infomart orders"
		manifest_tomorrow.online_shop_orders = get_woocommerce_orders(manifest_tomorrow.sales_date)
		puts "Updated tomorrow's Woocommerce orders"
		manifest_tomorrow.save
		manifest_two_days_from_now = Manifest.new(:sales_date => (Date.tomorrow + 1.day).strftime('%Y年%m月%d日'))
		manifest_two_days_from_now.infomart_orders = get_infomart(manifest_two_days_from_now.sales_date)
		puts "Updated tomorrow's Infomart orders for two days from now"
		manifest_two_days_from_now.online_shop_orders = get_woocommerce_orders(manifest_two_days_from_now.sales_date)
		puts "Updated Woocommerce orders for two days from now"
		manifest_two_days_from_now.save

		puts "Finished Tsuhan."

	end

	desc "Pull and replace data today and tomorrow's Rakuten order data"
	task :pull_rakuten => :environment do

		puts "Pulling Rakuten Data from API..."
		#Rakuten
		manifest_today = RManifest.where(:sales_date => Date.today.strftime('%Y年%m月%d日')).first
		manifest_today.nil? ? (manifest_today = RManifest.new(:sales_date => Date.today.strftime('%Y年%m月%d日'))) : ()
		manifest_today.get_order_details_by_api
		puts "Updated today's Rakuten orders"
		manifest_tomorrow = RManifest.where(:sales_date => Date.tomorrow.strftime('%Y年%m月%d日')).first
		manifest_tomorrow.nil? ? (manifest_tomorrow = RManifest.new(:sales_date => Date.tomorrow.strftime('%Y年%m月%d日'))) : ()
		manifest_tomorrow.get_order_details_by_api
		puts "Updated tomorrow's Rakuten orders"
		manifest_two_days_from_now = RManifest.where(:sales_date => (Date.tomorrow + 1.day ).strftime('%Y年%m月%d日')).first
		manifest_two_days_from_now.nil? ? (manifest_two_days_from_now = RManifest.new(:sales_date => (Date.tomorrow + 1.day ).strftime('%Y年%m月%d日'))) : ()
		manifest_two_days_from_now.get_order_details_by_api
		puts "Updated Rakuten orders for two days from today"

		puts "Finished."

	end

	desc "Pull and replace existing Rakuten order data"
	task :get_one_month_rakuten => :environment do
		range = Date.today..Date.today.end_of_month
		puts "Pulling " + Date.today.strftime('%B') + "'s Rakuten data records from API..."
		
		range.each_with_index do |date, i|
			rmanifest = RManifest.where(:sales_date => date.strftime('%Y年%m月%d日')).first
			rmanifest.nil? ? (rmanifest = RManifest.new(:sales_date => date.strftime('%Y年%m月%d日'))) : ()
			puts i.to_s
			rmanifest.get_order_details_by_api
		end

		puts "Finished."

	end

	desc "Pull and replace existing Rakuten order data"
	task :refresh_existing_rakuten => :environment do
		total_length = RManifest.all.length.to_s
		puts "Pulling " + total_length + " Rakuten Data records from API..."
		
		RManifest.all.each_with_index do |rmanifest, i|
			puts "Pulling ID#" + rmanifest.id.to_s
			puts i.to_s + ' of ' + total_length
			rmanifest.get_order_details_by_api
		end

		puts "Finished."

	end

end

desc "Pull all recent order data for today and tomorrow"
task pull_recent_order_data: :environment do
  Rake::Task['pull_order_data:pull_tsuhan'].execute
  Rake::Task['pull_order_data:pull_rakuten'].execute
end

desc "Scrape all Woocommerce Order Data for existing orders"
task refresh_all_online_shop: :environment do
	def get_woocommerce_orders(sales_date)
		require "json"

		wc_orders_json = JSON.load(open('https://www.funabiki.info/wp-json/wc/v3/orders?per_page=100&search=' + (DateTime.strptime(sales_date, '%Y年%m月%d日')).strftime("%Y-%m-%d") + '&consumer_key=' + ENV['WOOCOMMERCE_CONSUMER_KEY'] + '&consumer_secret=' + ENV['WOOCOMMERCE_CONSUMER_SECRET']))

		#iterates through each order and seperates items into their respective type (given a type)
		def fill_wc_hash(wc_orders, order, item, type)

			#iterates through the metadata and sets JSON arrayed k/v to hashed k/v
			def set_key_from_meta(wc_orders, order, type, meta_key, new_key)
				(order['meta_data'].select{|array| array["key"] == meta_key }).each do |k, v|
					wc_orders[type.to_sym][order["id"]][new_key.to_sym] = k["value"]
				end
			end
			#make the hash unless it's already there
			if !wc_orders[type.to_sym][order["id"]].is_a?(Hash) then wc_orders[type.to_sym][order["id"]] = Hash.new end

			#basic data set
			wc_orders[type.to_sym][order["id"]][:url] = 'https://funabiki.info/wp-admin/post.php?post=' + order["id"].to_s + '&action=edit'
			wc_orders[type.to_sym][order["id"]][:sender] = order['billing']
			wc_orders[type.to_sym][order["id"]][:recipent] = order['shipping']
			wc_orders[type.to_sym][order["id"]][:items] = order['line_items']
			#set from meta data
			set_key_from_meta(wc_orders, order, type, 'ywot_pick_up_date', 'shipping_date')
			set_key_from_meta(wc_orders, order, type, 'wc4jp-delivery-date', 'arrival_date')
			set_key_from_meta(wc_orders, order, type, 'ywot_tracking_code', 'tracking')
			set_key_from_meta(wc_orders, order, type, 'wc4jp-delivery-time-zone', 'arrival_time')
			set_key_from_meta(wc_orders, order, type, '熨斗タイプ', 'noshi')
			#raw data from JSON
			wc_orders[type.to_sym][order["id"]][:raw_data] = order

		end

		wc_orders = Hash.new
		wc_orders[:raw] = Hash.new
		wc_orders[:frozen] = Hash.new
		wc_orders_json.each do |order|
			order["line_items"].each do |item|
				if item["name"].include?('冷凍')
					type = "frozen"
					fill_wc_hash(wc_orders, order, item, type)
				else
					wc_orders[:raw]
					type ="raw"
					fill_wc_hash(wc_orders, order, item, type)
				end
			end
		end
		wc_orders
	end
	total_count = Manifest.all.count
	puts "Updating" + total_count.to_s + "manifests, this could take awhile, grab a coffee..."
	i = 0
	Manifest.all.each do |manifest|
		manifest.online_shop_orders = get_woocommerce_orders(manifest.sales_date)
		manifest.save
		i += 1
		puts "Updated #" + manifest.id.to_s + "(" + i.to_s + "of" + total_count.to_s + ")"
	end
	puts "Finished."
end

desc "Check for mail that needs to be sent and send it"
task mail_check_and_send: :environment do
	counter = 0
	OysterInvoice.all.each do |invoice|
		unless invoice.completed
			if invoice.send_at <= DateTime.now
				puts 'Sending mailer for invoice from ' + invoice.start_date + ' ~ ' + invoice.end_date
				InvoiceMailer.with(invoice: invoice).sakoshi_invoice_email.deliver_now
				InvoiceMailer.with(invoice: invoice).aioi_invoice_email.deliver_now
				invoice.completed = true
				invoice.data[:mail_sent] = DateTime.now
				invoice.save
				counter += 1
			end
		end
	end
	puts 'Sent ' + counter.to_s + ' e-mail(s)'
end


namespace :yahoo do

	desc "Get Yahoo Orders List (default one week, takes a time period parameter)"
	task refresh: :environment do
		YahooAPI.get_store_status
		YahooAPI.get_new_orders
	end


end