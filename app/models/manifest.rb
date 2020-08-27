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
		DateTime.strptime(nenngapi_date, '%Y年%m月%d日').strftime("%m月%d日")
	end

	def nengapi_to_date(nenngapi_date)
		DateTime.strptime(nenngapi_date, '%Y年%m月%d日')
	end

	def type_name(type)
		if type == :raw
			'生食用'
		elsif type == :frozen
			'プロトン凍結冷凍用'
		end
	end

	def wc_sender(wc_order)
		wc_order[:sender]["last_name"] + wc_order[:sender]["first_name"] 
	end

	def wc_recipent(wc_order)
		wc_order[:recipent]["last_name"] + wc_order[:recipent]["first_name"]
	end


	def wc_item_counts(item)
		shells = { 437 => [0, 0, 10, 0], 516 => [0, 0, 20, 0], 517 => [0, 0, 30, 0], 519 => [0, 0, 40, 0], 520 => [0, 0, 50, 0], 521 => [0, 0, 60, 0], 838 => [0, 0, 70, 0], 522 => [0, 0, 80, 0], 837 => [0, 0, 90, 0], 523 => [0, 0, 100, 0] }
		mukimi = { 583 => [1, 0, 0, 0], 581 => [2, 0, 0, 0], 580 => [3, 0, 0, 0], 579 => [4, 0, 0, 0], 578 => [5, 0, 0, 0], 577 => [6, 0, 0, 0], 6555 => [7, 0, 0, 0], 6556 => [8, 0, 0, 0], 6557 => [9, 0, 0, 0], 6558 => [10, 0, 0, 0], 6559 => [11, 0, 0, 0], 6560 => [12, 0, 0, 0] }
		sets = { 584 => [1, 0, 10, 0], 590 => [1, 0, 20, 0], 591 => [1, 0, 30, 0], 592 => [2, 0, 20, 0], 593 => [2, 0, 30, 0], 594 => [2, 0, 40, 0] }
		dekapuri = { 524 => [0, 1, 0, 0], 645 => [0, 2, 0, 0], 646 => [0, 3, 0, 0], 6554 => [0, 4, 0, 0] }
		rshells = { 13585 => [0, 0, 10, 0], 13584 => [0, 0, 20, 0], 13583 => [0, 0, 30, 0], 13582 => [0, 0, 40, 0], 13580 => [0, 0, 50, 0], 13579 => [0, 0, 60, 0], 13577 => [0, 0, 70, 0], 13586 => [0, 0, 80, 0], 13587 => [0, 0, 90, 0], 13588 => [0, 0, 100, 0] }
		other = { 596 => [0, 0, 0, "干えび(ムキ) 100g×3袋"], 595 => [0, 0, 0, "干えび(ムキ) 100g×5袋"], 598 => [0, 0, 0, "干えび(殻付)100g×10袋"], 599 => [0, 0, 0, "干えび(殻付)100g×3袋"], 600 => [0, 0, 0, "干えび(殻付)100g×5袋"], 597 => [0, 0, 0, "干えび(ムキ) 100g×2袋 + (殻付) 100g×2袋"], 572 => [0, 0, 0, "焼穴子 400g入"], 575 => [0, 0, 0, "焼穴子 550g入"], 576 => [0, 0, 0, "焼穴子 700g入"], 500 => [0, 0, 0, "牡蠣ナイフ"], 6319 => [0, 0, 0, "熨斗"] }
		hashes = [shells, mukimi, sets, dekapuri, rshells, other]
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
		frozen_ids = [524, 645, 646, 6554, 13585, 13584, 13583, 13582, 13580, 13579, 13577, 13586, 13587, 13588]
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

	def generate_empty_manifest
		Prawn::Document.generate("PDF.pdf", :page_size => "A4", :page_layout => :landscape, :margin => [25]) do |pdf_data|
			#document set up
			pdf_data.font_families.update("SourceHan" => {
				:normal => ".fonts/SourceHan/SourceHanSans-Normal.ttf",
				:bold => ".fonts/SourceHan/SourceHanSans-Bold.ttf",
				:light => ".fonts/SourceHan/SourceHanSans-Light.ttf",
			})
			#set utf-8 japanese font
			pdf_data.font "SourceHan" 
			#first page for raw oysters
				#print the date
				pdf_data.font_size 16
				pdf_data.font "SourceHan", :style => :bold
				pdf_data.text self.type + (self.type == '生食用' ? (( ' ' * (168))) : (' ' * (141))) + Date.today.strftime('%Y年%m月%d日')
				pdf_data.move_down 5
				pdf_data.font "SourceHan", :style => :normal

				#set up the data, make the header
				data_table = Array.new
				header_data_row = ['#', '注文者', 'お届け先', '500g', '1k', 'セル', '箱', 'お届け日', '時間', 'ナイフ', 'のし', '備考']
				data_table << header_data_row
				#add the rows
				def add_row(data_table, rows)
					data_table << ['　'] * rows
				end
				25.times { add_row(data_table, 12) }
				pdf_data.font_size 10
				pdf_data.table( data_table, :cell_style => {:border_width => 0.25, :padding => 4 }, :column_widths => { 0 => 18, 1 => 100, 2 => 70, 3 => 50, 4 => 50, 5 => 100, 6 => 50, 7 => 50, 8 => 65, 9 => 50, 10 => 40 }, :width => 780 ) do
					rows(0..-1).each do |r|
						r.height = 20 if r.height < 20
					end

					center_columns = [ columns(0), columns(2..4), columns(7..11) ]
					center_columns.each do |r|
						r.style( align: :center )
					end

					header_cells = cells.columns(0..-1).rows(0)
					header_cells.background_color = "acacac"
					header_cells.size = 10
					header_cells.font_style = :bold
				end
			return pdf_data
		end
	end

	def get_woocommerce_orders
		require "json"

		wc_orders_json = JSON.load(open('https://www.funabiki.info/wp-json/wc/v3/orders?per_page=100&search=' + (DateTime.strptime(self.sales_date, '%Y年%m月%d日')).strftime("%Y-%m-%d") + '&consumer_key=' + ENV['WOOCOMMERCE_CONSUMER_KEY'] + '&consumer_secret=' + ENV['WOOCOMMERCE_CONSUMER_SECRET']))

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
		login_form = page.form('form01')
		#login
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

	def do_pdf
		require "moji"

		infomart_raw_data = self.infomart_orders[:raw]
		informart_frozen_data = self.infomart_orders[:frozen]
		online_shop_raw_data = self.online_shop_orders[:raw]
		online_shop_frozen_data = self.online_shop_orders[:frozen]
		# 210mm x 297mm
		Prawn::Document.generate("PDF.pdf", :page_size => "A4", :page_layout => :landscape, :margin => [25]) do |pdf|
			#document set up
			pdf.font_families.update("SourceHan" => {
				:normal => ".fonts/SourceHan/SourceHanSans-Normal.ttf",
				:bold => ".fonts/SourceHan/SourceHanSans-Bold.ttf",
				:light => ".fonts/SourceHan/SourceHanSans-Light.ttf",
			})
			#set utf-8 japanese font
			pdf.font "SourceHan" 

			#first page for raw oysters
				#print the date
				pdf.font_size 16
				pdf.font "SourceHan", :style => :bold
				pdf.text  '生食用 InfoMart/WooCommerce 発送表' + ( ' ' * 99 ) + self.sales_date
				pdf.move_down 7
				pdf.font "SourceHan", :style => :normal

				#set up the data, make the header
				data_table = Array.new
				header_data_row = ['#', '注文者', 'お届け先', '500g', '1k', 'セル', '箱', 'お届け日', '時間', 'ナイフ', 'のし', '備考']
				data_table << header_data_row
				#add the rows
				i = 0
				used_row_count = 0
				def add_row(data_table, rows)
					data_table << ['　'] * rows
				end
				#raw infomart orders
				infomart_raw_data.each do |order_id, order|
					order[:items].reverse_each do | item_number, details |
						if same_day(order) || two_days(order)
							order_data_row = Array.new
							used_row_count += 1
							# make a new array for this order row
							# order numner
							if details[:item_name].exclude?("坂越バラ牡蠣") || ( details[:item_name].include?("坂越バラ牡蠣") && (order[:items].length < 2) )
								i += 1
								order_data_row << i
							else
								order_data_row << '↳'
							end
							#client name
							order_data_row << client_nicknames(order[:client])
							#recipent name
							order_data_row << '""'
							#500
							if details[:item_name].include?("500g")
								order_data_row << details[:item_count].to_s
							else
								order_data_row << ''
							end
							#1k
							if details[:item_name].include?("1k")
								order_data_row << '1k ×' + details[:item_count].to_s
							else
								order_data_row << ''
							end
							#shells
							if details[:item_name].include?("殻付き生牡蠣")
								if details[:item_count].to_i > 130
									order_data_row << '(' + details[:item_count].to_s + '個)'
								else
									order_data_row << details[:item_count].to_s + '個'
								end
							elsif details[:item_name].include?("坂越バラ牡蠣")
								order_data_row << 'バラ牡蠣' + details[:item_count].to_s + '㎏'
							else
								order_data_row << ''
							end
							#box
							order_data_row << 'YT-'
							#arrival date
							arrival = DateTime.strptime(order[:arrival][/\d.*\/+\d./].to_s, "%Y/%m/%d").strftime("%m月%d日")
							order_data_row << arrival
							#arrival time
							order_data_row << '午前　14-16'
							#knife
							order_data_row << ''
							#noshi
							order_data_row << ''
							#notes
							order_data_row << ''
							#add the array to the list of arrays that will become table rows
							data_table << order_data_row
							if details[:item_name].include?("殻付き生牡蠣") && details[:item_count].to_i > 130
								used_row_count += 1
								data_table << ['↳'] + [client_nicknames(order[:client])] + ['""'] + (['　'] * 2) + ['↳'] + ['YT-'] + [arrival] + ['午前　14-16'] + (['　'] * 3)
							end
						end
					end
				end
				#raw online shop orders
				online_shop_raw_data.each do |order_id, wc_order|
					i += 1
					ic = 0
					wc_order[:items].each do |item|
						if check_raw(item)
							count = wc_item_counts(item)
							order_data_row = Array.new
							used_row_count += 1
							#continue orer number
							order_data_row << if ic == 0 then i else '' end
							ic += 1
							# sender
							order_data_row << 'Ⓕ ' + wc_sender(wc_order)
							# recipient
							order_data_row << if wc_sender(wc_order) == wc_recipent(wc_order) then '""' else wc_recipent(wc_order) end
							# 500g mukimi
							mukimi500 = print_count(count)
							order_data_row << if !mukimi500.nil? then mukimi500 else '' end
							# 1k mukimi
							mukimi1k = print_count(count)
							order_data_row << if !mukimi1k.nil? then '1k × ' + mukimi1k else '' end
							# shells
							shells = print_count(count)
							order_data_row << if !shells.nil? then shells + '個' else '' end
							# box input
							order_data_row << 'YT-'
							# arrival date
							print_date = nengapi_to_gapi_date(Moji.zen_to_han(wc_order[:arrival_date]))
							order_data_row << print_date
							# arrival time
							order_data_row << if wc_order[:arrival_time] then wc_order[:arrival_time].gsub(':00', '') end
							# knife
							order_data_row << if item[:id] == 500 then item[:quantity] else '' end
							# noshi
							order_data_row << if (!wc_order[:noshi].nil? && wc_order[:noshi].exclude?('必要ない')) then wc_order[:noshi] else '' end
							# notes
							order_data_row << print_count(count)
							data_table << order_data_row
						end
					end
				end

				pdf.font_size 10
				pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :padding => 4 }, :column_widths => { 0 => 18, 1 => 100, 2 => 70, 3 => 50, 4 => 50, 5 => 100, 6 => 50, 7 => 50, 8 => 65, 9 => 50, 10 => 40 }, :width => 780 ) do
					rows(0..-1).each do |r|
						r.height = 20 if r.height < 20
					end

					center_columns = [ columns(0), columns(2..4), columns(7..11) ]
					center_columns.each do |r|
						r.style( align: :center )
					end

					header_cells = cells.columns(0..-1).rows(0)
					header_cells.background_color = "acacac"
					header_cells.size = 10
					header_cells.font_style = :bold
				end

				#Extra rows to fill up for raw orders
				data_table = Array.new
				fill_rows = pdf.page_count * 22
				(fill_rows - used_row_count).times { add_row(data_table, 12) }
				first_table_page_count = pdf.page_count
				if !data_table.empty?
					pdf.table( data_table, :cell_style => {:border_width => 0.25, :padding => 4 }, :column_widths => { 0 => 18, 1 => 100, 2 => 70, 3 => 50, 4 => 50, 5 => 100, 6 => 50, 7 => 50, 8 => 65, 9 => 50, 10 => 40 }, :width => 780 )
				end

			#second page for frozen oysters
				pdf.start_new_page
				#print the date
				pdf.font_size 16
				pdf.font "SourceHan", :style => :bold
				pdf.text  'プロトン凍結冷凍用 InfoMart/WooCommerce 発送表' + ( ' ' * 73 ) + self.sales_date
				pdf.move_down 7
				pdf.font "SourceHan", :style => :normal

				#set up the data, make the header
				data_table = Array.new
				header_data_row = ['#', '注文者', 'お届け先', '500g
					Lサイズ', '500g
					LLサイズ', '500g
					生食用WDI
					Lサイズ', 'セル', 'JPセル', 'お届け日', '時間', '備考']
				data_table << header_data_row
				#add the rows
				i = 0
				used_row_count = 0
				informart_frozen_data.each do | order_id, order |
					order[:items].each do | item_number, details |
						#if expected_arrival == order[:arrival][/\d.*\/+\d./] || order[:client].include?("ｏｃｅａｎ") || order[:client].include?("那覇")
						if same_day(order) || two_days(order)
						i += 1
						# make a new array for this order row
							order_data_row = Array.new
							used_row_count += 1
							# make a new array for this order row
							# order numner
							order_data_row << i
							#client name
							order_data_row << client_nicknames(order[:client])
							#recipent name
							order_data_row << '""'
							#500L
							if details[:item_name].include?("デカプリオイスター") && details[:item_name].exclude?("大粒") && details[:item_name].exclude?("LL") && details[:item_name].exclude?("岡山県産") && order[:client].exclude?("ブリーズオブ東京")  && order[:client].exclude?("オイスターバー品川店")
								order_data_row << ( if details[:item_name].include? "×20" then '20 × ' else '500g ×' end ) + details[:item_count]
							else
								order_data_row << ''
							end
							#500LL size
							if details[:item_name].include?("デカプリオイスター") && (details[:item_name].include?("大粒") or details[:item_name].include?("LL")) && order[:client].exclude?("ブリーズオブ東京") && order[:client].exclude?("オイスターバー品川店") or details[:item_name].include?("岡山県産") && details[:item_name].include?("デカプリオイスター")
								order_data_row << ( (details[:item_name].include? "岡山") ? ('㊐ ') : ('') ) + ( if details[:item_name].include? "×20" then '20 × ' + details[:item_count] elsif details[:item_name].include? "×10" then '10 × ' + details[:item_count] else '500g ×' + details[:item_count] end )
							else
								order_data_row << ''
							end
							#500LL WDI Raw
							if order[:client].include?("ブリーズオブ東京") || order[:client].include?("オイスターバー品川店")
								order_data_row << ( if details[:item_name].include? "×20" then '20 × ' else '500g ×' end ) + details[:item_count]
							else
								order_data_row << ''
							end
							#shells
							if details[:item_name].include?("冷凍殻付き牡蠣サムライオイスター")
								order_data_row << '100個 × ' + details[:item_count]
							elsif details[:item_name].include?("冷凍　殻付き牡蠣サムライオイスター")
								order_data_row << details[:item_count] + '個 × 1'
							else
								order_data_row << ''
							end
							#JP shells
							if details[:item_name].include?("生食用プロトンセル牡蠣120個")
								order_data_row << '120個 × ' + details[:item_count]
							else
								order_data_row << ''
							end
							#arrival date
							order_data_row << DateTime.strptime(order[:arrival][/\d.*\/+\d./].to_s, "%Y/%m/%d").strftime("%m月%d日")
							#arrival time
							order_data_row << '午前  14-16'
							#notes
							order_data_row << '                                               '
							#add the array to the list of arrays that will become table rows
							data_table << order_data_row
						end
					end
				end
				#frozen online ship orders
				online_shop_frozen_data.each do |order_id, wc_order|
					wc_order[:items].each do |item|
						if check_frozen(item)
							count = wc_item_counts(item)
							order_data_row = Array.new
							used_row_count += 1
							#continue orer number
							i += 1
							order_data_row << i
							# sender
							order_data_row << 'Ⓕ ' + wc_sender(wc_order)
							# recipient
							order_data_row << if wc_sender(wc_order) == wc_recipent(wc_order) then '""' else wc_recipent(wc_order) end
							# l size
							lsize = print_count(count)
							order_data_row << if !lsize.nil? then '500g × ' + lsize else '' end
							# ll size
							llsize = print_count(count)
							order_data_row << if !llsize.nil? then '500g × ' + llsize else '' end
							# wdi
							order_data_row << ''
							# shells
							rshells = print_count(count)
							order_data_row << if !rshells.nil? then rshells + '個' else '' end
							#JP spacer
							order_data_row << ''
							# arrival date
							print_date = nengapi_to_gapi_date(Moji.zen_to_han(wc_order[:arrival_date]))
							order_data_row << print_date
							# arrival time
							order_data_row << if wc_order[:arrival_time] then wc_order[:arrival_time].gsub(':00', '') end
							# notes
							order_data_row << if print_count(count).is_a?(String) then print_count(count) else '' end
							data_table << order_data_row
						end
					end
				end

				pdf.font_size 10
				pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :padding => 4}, :column_widths => { 0 => 18, 1 => 180, 2 => 50, 3 => 60, 4 => 60, 5 => 60, 6 => 55, 7 => 55, 8 => 55, 9 => 60 }, :width => 780 ) do
					rows(0..-1).each do |r|
						r.height = 20 if r.height < 20
					end

					center_columns = [ columns(0), columns(2..10) ]
					center_columns.each do |r|
						r.style( align: :center )
					end

					header_cells = cells.columns(0..-1).rows(0)
					header_cells.background_color = "acacac"
					header_cells.size = 10
					header_cells.font_style = :bold
				end

				#Extra rows to fill up the sheet for frozen 
				data_table = Array.new
				fill_rows = (pdf.page_count - first_table_page_count) * 22
				(fill_rows - used_row_count).times { add_row(data_table, 11) }
				if !data_table.empty?
					pdf.table( data_table, :cell_style => {:border_width => 0.25, :padding => 4}, :column_widths => { 0 => 18, 1 => 180, 2 => 50, 3 => 60, 4 => 60, 5 => 60, 6 => 55, 7 => 55, 8 => 55, 9 => 60 }, :width => 780 )
				end
				
			#render in the browser (takes server ram until closed)
			return pdf
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
