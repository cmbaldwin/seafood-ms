class Manifest < ApplicationRecord
	has_many :restaurant_and_manifest_joins
	has_many :restaurants, through: :restaurant_and_manifest_joins

	serialize :infomart_orders
	serialize :online_shop_orders
	attr_accessor :type

	validates_presence_of :sales_date
	validates_uniqueness_of :sales_date

	include OrderQuery
	order_query :manifest_query,
		[:sales_date] # Sort :sales_date in :desc order

	def slash_date(nenngapi_date)
		DateTime.strptime(nenngapi_date, '%Y年%m月%d日').strftime("%Y/%m/%d")
	end

	def nengapi_to_gapi_date(nenngapi_date)
		if nenngapi_date.include?("年")
			DateTime.strptime(nenngapi_date, '%Y年%m月%d日').strftime("%m月%d日")
		else
			DateTime.parse(nenngapi_date).strftime("%m月%d日")
		end
	end

	def nengapi_to_date(nenngapi_date)
		DateTime.strptime(nenngapi_date, '%Y年%m月%d日')
	end

	def date
		nengapi_to_date(self.sales_date)
	end

	def type_name(type)
		if type == :raw
			'生食用'
		elsif type == :frozen
			'冷凍用'
		end
	end

	def wc_sender(wc_order)
		wc_order[:sender]["last_name"] + wc_order[:sender]["first_name"]
	end

	def wc_recipent(wc_order)
		wc_order[:recipent]["last_name"] + wc_order[:recipent]["first_name"]
	end


	def wc_item_counts(item)
		shells = {
			437 => [0, 0, 10, 0, 0],
			516 => [0, 0, 20, 0, 0],
			517 => [0, 0, 30, 0, 0],
			519 => [0, 0, 40, 0, 0],
			520 => [0, 0, 50, 0, 0],
			521 => [0, 0, 60, 0, 0],
			838 => [0, 0, 70, 0, 0],
			522 => [0, 0, 80, 0, 0],
			837 => [0, 0, 90, 0, 0],
			523 => [0, 0, 100, 0, 0] }
		small_shells = {
			13867 => [0, 0, 0, 0, 1],
			13883 => [0, 0, 0, 0, 2],
			13884 => [0, 0, 0, 0, 3],
			13885 => [0, 0, 0, 0, 5], }
		mukimi = {
			583 => [1, 0, 0, 0, 0],
			581 => [2, 0, 0, 0, 0],
			580 => [3, 0, 0, 0, 0],
			579 => [4, 0, 0, 0, 0],
			578 => [5, 0, 0, 0, 0],
			577 => [6, 0, 0, 0, 0],
			6555 => [7, 0, 0, 0, 0],
			6556 => [8, 0, 0, 0, 0],
			6557 => [9, 0, 0, 0, 0],
			6558 => [10, 0, 0, 0, 0],
			6559 => [11, 0, 0, 0, 0],
			6560 => [12, 0, 0, 0, 0] }
		sets = {
			584 => [1, 0, 10, 0, 0],
			590 => [1, 0, 20, 0, 0],
			591 => [1, 0, 30, 0, 0],
			592 => [2, 0, 20, 0, 0],
			593 => [2, 0, 30, 0, 0],
			594 => [2, 0, 40, 0, 0] }
		dekapuri = {
			524 => [0, 1, 0, 0, 0],
			645 => [0, 2, 0, 0, 0],
			646 => [0, 3, 0, 0, 0],
			6554 => [0, 4, 0, 0, 0],
			13551 => [0, 10, 0, 0, 0],
			13552 => [0, 20, 0, 0, 0] }
		rshells = {
			13585 => [0, 0, 10, 0, 0],
			13584 => [0, 0, 20, 0, 0],
			13583 => [0, 0, 30, 0, 0],
			13582 => [0, 0, 40, 0, 0],
			13580 => [0, 0, 50, 0, 0],
			13579 => [0, 0, 60, 0, 0],
			13577 => [0, 0, 70, 0, 0],
			13586 => [0, 0, 80, 0, 0],
			13587 => [0, 0, 90, 0, 0],
			13588 => [0, 0, 100, 0, 0] }
		other = {
			596 => [0, 0, 0, "干えび(ムキ) 100g×3袋", 0],
			595 => [0, 0, 0, "干えび(ムキ) 100g×5袋", 0],
			598 => [0, 0, 0, "干えび(殻付)100g×10袋", 0],
			599 => [0, 0, 0, "干えび(殻付)100g×3袋", 0],
			600 => [0, 0, 0, "干えび(殻付)100g×5袋", 0],
			597 => [0, 0, 0, "干えび(ムキ) 100g×2袋 + (殻付) 100g×2袋", 0],
			572 => [0, 0, 0, "焼穴子 400g入", 0],
			575 => [0, 0, 0, "焼穴子 550g入", 0],
			576 => [0, 0, 0, "焼穴子 700g入", 0],
			500 => [0, 0, 0, "牡蠣ナイフ", 0],
			6319 => [0, 0, 0, "熨斗", 0] }
		hashes = [shells, small_shells, mukimi, sets, dekapuri, rshells, other]
		all_items = hashes.inject(&:merge)
		if all_items.key?(item["product_id"])
			all_items[item["product_id"]]
		else
			["???", "???", "???", "???"]
		end
	end

	def display_totals
		totals = Hash.new
		totals[:gohyaku] = 0
		totals[:shells] = 0
		totals[:bara] = 0
		totals[:cards] = 0
		if self.online_shop_orders[:raw]
			self.online_shop_orders[:raw].each do |order, order_data|
				order_data[:items].each do |item|
					totals[:gohyaku] += wc_item_counts(item)[0]
					totals[:shells] += wc_item_counts(item)[2]
					totals[:bara] += wc_item_counts(item)[4]
					(wc_item_counts(item)[2] > 0) ? (totals[:cards] += 1) : ()
				end
			end
		end
		if self.infomart_orders[:raw]
			self.infomart_orders[:raw].each do |order, order_data|
				if same_day(order_data) || two_days(order_data) || fresh_order(order_data)
					order_data[:items].each do |item, item_data|
						item_data[:item_name].include?("500g") ? (totals[:gohyaku] += item_data[:item_count].to_i) : ()
						if item_data[:item_name].include?("殻付き")
							totals[:shells] += item_data[:item_count].to_i
							totals[:cards] += 1
						end
						item_data[:item_name].include?("バラ牡蠣") ? (totals[:bara] += item_data[:item_count].to_i) : ()
					end
				end
			end
		end
		totals[:gohyaku] = totals[:gohyaku].to_s + 'p'
		totals[:shells] = totals[:shells].to_s + '個'
		totals[:bara] = totals[:bara].to_s + '㎏'
		totals[:cards] = totals[:cards].to_s + '枚'
		totals
	end

	def frozen_ids
		[524, 645, 646, 6554, 13585, 13552, 13551, 13584, 13583, 13582, 13580, 13579, 13577, 13586, 13587, 13588]
	end

	def expected_arrival
		date = (DateTime.strptime(self.sales_date, '%Y年%m月%d日') + 1).strftime("%Y/%m/%d")
		date
	end

	def two_day_arrival
		date = (DateTime.strptime(self.sales_date, '%Y年%m月%d日') + 2).strftime("%Y/%m/%d")
		date
	end

	def same_day(order_details)
		( expected_arrival == order_details[:arrival][/\d.*\/+\d./] && order_details[:client].exclude?("ｏｃｅａｎ") && order_details[:client].exclude?("那覇") )
	end

	def two_days(order_details)
		if expected_arrival != order_details[:arrival][/\d.*\/+\d./]
			if order_details[:client].include?("ｏｃｅａｎ") || order_details[:client].include?("那覇")
				two_day_arrival == order_details[:arrival][/\d.*\/+\d./]
			end
		end
	end

	def unchecked_arrival_today
		date = (DateTime.strptime(self.sales_date, '%Y年%m月%d日')).strftime("%Y/%m/%d")
		date
	end

	def unchecked_arrival_yeterday
		date = (DateTime.strptime(self.sales_date, '%Y年%m月%d日')).strftime("%Y/%m/%d")
		date
	end

	def fresh_order(order_details)
		if order_details[:fresh]
			( (unchecked_arrival_today == order_details[:arrival][/\d.*\/+\d./] || unchecked_arrival_yeterday == order_details[:arrival][/\d.*\/+\d./]) && order_details[:client].exclude?("ｏｃｅａｎ") && order_details[:client].exclude?("那覇") )
		else
			false
		end
	end

	def shinki_im_orders
		orders = Hash.new
		i = 0
		[:raw, :frozen].each do |key|
			orders[key] = Hash.new unless orders[key].is_a?(Hash)
			self.infomart_orders[key].each do |order_id, order_details|
				if order_details[:fresh]
					orders[key][order_id] = order_details
					i += 1
				end
			end
		end
		orders[:total] = i
		orders
	end

	def check_raw(item)
		#true for raw, so if frozen id is found return false
		frozen_ids.exclude?(item["product_id"])
	end

	def check_frozen(item)
		#true for frozen, so if frozen id is found return true
		frozen_ids.include?(item["product_id"])
	end

	def client_nicknames(client_name)
		deletions = Array.new
		deletions << '（ジャックポットプランニング）'
		deletions << '（(株)オペレーションファクトリー東京）'
		deletions << '（(株)オペレーションファクトリー）'
		deletions << '（(株)ＷＤＩ　ＪＡＰＡＮ）'
		deletions << '（モンテステリース(有)）'
		deletions << '（(株)リバリュース）'
		deletions << '（ＳＷ）'
		deletions.each do |delete|
			client_name.slice! delete
		end
		substitutions = Array.new
		substitutions << ['ジャックポット', 'JP　']
		substitutions.each do |substitution|
			client_name.gsub!(substitution[0], substitution[1])
		end
		client_name
	end

	def print_count(count)
		current = count.shift
		if current.is_a?(Integer) && current > 0
			current.to_s
		elsif current.is_a?(String)
			current
		end
	end

	def get_woocommerce_orders
		require "json"

		date = (DateTime.strptime(self.sales_date, '%Y年%m月%d日')).strftime("%Y-%m-%d")
		#get up to 100 orders from the 'orders' api endpoint and search for the date with slashes as a term
		wc_orders_json = WCAPI.new('orders', '100', date).response

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
		self.online_shop_orders = wc_orders
		wc_orders_json = nil
	end

	def get_infomart_csv
		require 'mechanize'
		require 'csv'

		puts "Loading..."
		agent = Mechanize.new
		#today's date
		slash_date = DateTime.now.strftime("%Y/%m/%d")
		puts "Scraping CSV download link for " + slash_date
		page = agent.get('https://www2.infomart.co.jp/trade/download/bat_detail.pagex?1')
		puts "Logging in..."
		login_form = page.form('form01')
		#login
		login_form.UID = ENV['INFOMART_LOGIN']
		login_form.PWD = ENV['INFOMART_PASS']
		page = agent.submit(login_form)
		#we're in, list the availiable recent dates
		puts "Logged in scraping for a suitable link"
		page.search('tr.slip-summary-a').each do |row|
			i = 0
			if (row.search('td.list-cell')[1].text.include?(slash_date)) && (i == 0)
				puts "Link candidate found."
				row.search('a.ic-blu-dl').each do |download_link|
					@download_link = 'https://ec.infomart.co.jp/trade/download/download_inside_caller.aspx?file_id=%20&call_file=' + download_link["href"][/(?<=').*\.asp/]
					puts "Found: \"" + @download_link + "\""
					puts "Grabbing the CSV data and importing it"
					csv = agent.get(@download_link).body
					puts "Raw Data \n" + csv
					data = CSV.parse(csv, encoding:'Shift_JIS', headers: true) do |row|
					end
					i += 1
				end
			else
				puts "No data found for today yet." if i == 0
			end
		end
		puts "Finished."
	end

	def get_infomart
		require 'mechanize'

		agent = Mechanize.new
		#today's date
		scrape_date = DateTime.strptime(self.sales_date, '%Y年%m月%d日')
		start_date = (scrape_date - 1).strftime("%Y/%m/%d")
		end_date = (scrape_date + 2).strftime("%Y/%m/%d")
		#go to the page to scrape
		page = agent.get('https://www2.infomart.co.jp/employment/shipping_list_window.page?6&st=0&parent=1&selbuy=0&op=00&f_date=' + start_date + '&t_date=' + end_date + '&stmnm&stmtel&HTradeState&resend&membersel=0&mcd_child&membernm&pdate=2&Infl=TC&TCalTradeState=0&TCalTradeState_2=0&TCalTradeState_3=0&TCalTradeState_4=0&TCalTradeState_5=0&TCalTradeState_6=0&TCalTradeState_7=1&TransitionPage_Cal=1&LeaveCond=1&perusal=0&cwflg=1')
		login_form = page.form
		#error login?
		login_form.UID = ENV['INFOMART_LOGIN']
		login_form.PWD = ENV['INFOMART_PASS']
		page = agent.submit(login_form)
		#login again
		login_form = page.form('form01')
		login_form.UID = ENV['INFOMART_LOGIN']
		login_form.PWD = ENV['INFOMART_PASS']
		page = agent.submit(login_form)
		#we're in, set up the hashes
		orders = Hash.new
		orders[:raw] = Hash.new
		orders[:frozen] = Hash.new
		#find the order rows
		page.search('tbody.slip-summary-a').each do |order|
			#get the number of row so we can find how many of them are item rows (three rows are headers and spacers, so we can get items by getting total rows and subtracting three)
			row_count = order.search('tr').length
			#check if the order is fresh or has been dealt with already (if it's got '発注' in the header, it's fresh, so true)
			fresh = order.search('tr')[0].search('td')[0].text.to_s.include?('発注')
			#find the order number
			order_number = order.search('tr')[0].search('td')[1].text.to_s.to_sym
			backend_order_id = order.search('tr')[0].search('td')[6].to_s[/(?<=mfOpenTradeDetail\(')\d.*(?=',)/]
			#find client and arrival
			client = order.search('tr')[0].search('td')[4].text.to_s.gsub("保存","")
			arrival = order.search('tr')[1].search('td')[0].text.to_s
			#set restaurant
			restaurant = Restaurant.find_by(namae: client)
			if !restaurant.nil?
				#do nothing
			else
				restaurant = Restaurant.new(namae: client, link: client)
				if restaurant.save
					#do nothing
				else
					p restaurant.errors
				end
			end
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
							#add the restaurant product association
							restaurant.products.nil? ? restaurant.products = Hash.new : ()
							restaurant.products[type].nil? ? restaurant.products[type] = Hash.new : ()
							fixed_item_name = item_name.match(/(?!\r).*/).to_s.chomp.gsub('/ｃｓ\r', '')
							if restaurant.products[type][fixed_item_name].nil?
								#this product association has not yet been set
								restaurant.products[type][fixed_item_name] = 0
							end
							#make the hash for the order if it's not there
							if !orders[:frozen][order_number].is_a?(Hash) then orders[:frozen][order_number] = Hash.new end
								orders[:frozen][order_number][:backend_id] = backend_order_id
								orders[:frozen][order_number][:client] = client
								orders[:frozen][order_number][:arrival] = arrival
								orders[:frozen][order_number][:fresh] = fresh
								orders[:frozen][order_number][:restaurant_id] = restaurant.id
								#make the order items hash if it it's not there
								if !orders[:frozen][order_number][:items].is_a?(Hash) then orders[:frozen][order_number][:items] = Hash.new end
									orders[:frozen][order_number][:items][item_number] = Hash.new
											orders[:frozen][order_number][:items][item_number][:item_name] = item_name
											orders[:frozen][order_number][:items][item_number][:item_count] = item_count
						#if it's not frozen it must be raw
						else
							#add the restaurant product association
							restaurant.products.nil? ? restaurant.products = Hash.new : ()
							restaurant.products[type].nil? ? restaurant.products[type] = Hash.new : ()
							restaurant.products[type][item_name.match(/(?!\r).*/).to_s.chomp.gsub('/ｃｓ\r', '')] = 0

							#make the hash for the order if it's not there
							if !orders[:raw][order_number].is_a?(Hash) then orders[:raw][order_number] = Hash.new end

							# fill it in
							orders[:raw][order_number][:backend_id] = backend_order_id
							orders[:raw][order_number][:client] = client
							orders[:raw][order_number][:arrival] = arrival
							orders[:raw][order_number][:fresh] = fresh
							orders[:raw][order_number][:restaurant_id] = restaurant.id

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
		self.infomart_orders = orders
		self.infomart_orders.each_with_index do |(type, type_hash), oi|
			oi == 0 ? self.restaurants.destroy_all : ()
			type_hash.each do |order_number, order_hash|
				if same_day(order_hash) || two_days(order_hash) || fresh_order(order_hash)
					if order_hash[:restaurant_id]
						restaurant = Restaurant.find(order_hash[:restaurant_id])
						self.restaurants << restaurant
					end
				end
			end
		end
	end

	def get_new_associations
		new_associations = Array.new
		assocations = Product.all.pluck(:infomart_association, :id)
		self.infomart_orders.each do |type, orders|
			orders.each do |order_number, order_details|
				order_details[:items].each do |item_number, item_details|
					found = false
					assocations.each do |assoc_wid|
						assoc_hash = assoc_wid[0]
						if assoc_hash
							assoc_hash.each do |infomart_name, count|
								infomart_name == item_details[:item_name] ? found = true : ()
							end
						end
					end
					unless found
						new_associations << item_details[:item_name]
					end
				end
			end
		end
		new_associations
	end

	def check_for_links(product_name)
		links = Array.new
		self.infomart_orders.each do |type, orders|
			orders.each do |order_number, order_details|
				order_details[:items].each do |item_number, item_details|
					product_name == item_details[:item_name] ? (links << order_details[:backend_id]) : ()
				end
			end
			links.flatten
		end
		links
	end

end
