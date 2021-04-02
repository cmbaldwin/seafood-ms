class CSVWriter

	require 'csv'

	def free_shipping_csv(start_date, end_date)
		write_csv(collect_online_shop_data(start_date, end_date), "free_shipping_data_#{start_date.to_s(:number)}_#{end_date.to_s(:number)}")
	end

	def collect_online_shop_data(start_date, end_date)
		def nengapi(date)
			date.strftime("%Y年%m月%d日")
		end
		def reformat_date(date)
			DateTime.parse(date).strftime("%Y/%m/%d")
		end
		def zip_code_length_fix(zip_code)
			if zip_code.length < 7
				(zip_code.to_s + ((7 - zip_code.length) * '0')).to_s
			else
				zip_code.to_s
			end
		end
		series = start_date - 2.weeks..end_date + 1.day #in case some orders took longer to arrive and be registered
		nengapi_series = series.map{|date| nengapi(date)}
		yamato_numbers_list = Array.new

		#Rakuten
		rakuten_shop_code = 'S5420-30'
		rakuten_url = 'https://item.rakuten.co.jp/oyster-sisters/'
		rakuten_orders = Array.new
		RManifest.where(sales_date: nengapi_series).each do |manifest|
			manifest.new_orders_hash.each do |order|
				unless order[:raw_data]["orderProgress"] == 900
					rakuten_orders << order
				end
			end
		end
		rakuten_data = Array.new
		rakuten_orders.each do |order| 
			zip_code = "#{order[:sender]["zipCode1"]}#{order[:sender]["zipCode2"]}"
			order[:items].each_with_index do |item_hash, i| 
				current_number = order[:yamato_numbers][i].nil? ? (order[:yamato_numbers].first.nil? ? '' : order[:yamato_numbers].first.gsub('-', '')) : order[:yamato_numbers][i].gsub('-', '')
				unless current_number.empty?
					unless yamato_numbers_list.include?(current_number)
						rakuten_data << [ 
							rakuten_shop_code, 
							order[:raw_data]["orderNumber"], 
							reformat_date(order[:raw_data]["orderDatetime"]), 
							"#{rakuten_url}#{item_hash["manageNumber"]}/",
							item_hash["units"].to_s,
							'10',
							current_number,
							zip_code_length_fix(zip_code)
						]
						yamato_numbers_list << current_number
					end
				end
			end
		end

		#Funabiki Online
		def item_url(item_id)
			product_list_hash = {"13583" => "p30",
			"13584" => "p20",
			"13585" => "p10",
			"13552" => "protonx20",
			"13551" => "protonx10",
			"6554" => "protonx4",
			"646" => "protonx3",
			"645" => "protonx2",
			"524" => "proton",
			"13885" => "syoukara5kg",
			"13884" => "syoukara3kg",
			"13883" => "syoukara2kg",
			"13867" => "syoukara1kg",
			"593" => "302",
			"592" => "202",
			"591" => "301",
			"590" => "201",
			"584" => "101",
			"523" => "100",
			"837" => "90",
			"522" => "80",
			"838" => "70",
			"521" => "60",
			"520" => "50",
			"519" => "40",
			"517" => "30",
			"516" => "20",
			"437" => "10",
			"6560" => "12",
			"6559" => "11",
			"6558" => "10-2",
			"6557" => '9',
			"6556" => '8',
			"6555" => '7',
			"577" => '6',
			"578" => '5',
			"579" => '4',
			"580" => '3',
			"581" => '2',
			"583" => '1'}
			return nil if !product_list_hash.include?(item_id)
			"https://funabiki.info/product/#{(product_list_hash[item_id])}/"
		end
		funabiki_online_shop_code = 'S5420-10'
		funabiki_online_data = Array.new
		Manifest.where(sales_date: nengapi_series).each do |manifest|
			[:raw, :frozen].each do |type|
				manifest.online_shop_orders[type].each do |order_number, details|
					tracking = details[:tracking].split('　')
					unless tracking.empty?
						unless yamato_numbers_list.include?(tracking)
							details[:items].each_with_index do |item_hash, i|
								item_code = item_url(item_hash["product_id"].to_s)
								unless item_code.nil? || item_code.empty?
									funabiki_online_data << [
										funabiki_online_shop_code,
										order_number.to_s,
										reformat_date(details[:raw_data]["date_created"]),
										item_code,
										item_hash["quantity"].to_s,
										'10',
										tracking[i].nil? ? (tracking.first.nil? ? '' : tracking.first.gsub('-', '')) : tracking[i].gsub('-', ''),
										zip_code_length_fix(details[:recipent]["postcode"].gsub('-', ''))
									]
									yamato_numbers_list << tracking
								end
							end
						end
					end
				end
			end	
		end
		
		#Yahoo Shopping
		yahoo_shop_code = 'S5420-20'
		yahoo_shopping_data = Array.new
		YahooOrder.where(ship_date: series).each do |order|
			# Attempt to update order if missing Shipping Invoice Number
			if order[:details]["Ship"]["ShipInvoiceNumber1"].nil?
				YahooAPI.new(User.find(1)).refresh_single_order_details(order[:order_id])
			end
			unless order[:details]["Ship"]["ShipInvoiceNumber1"].nil?
				tracking = order[:details]["Ship"]["ShipInvoiceNumber1"] ? order[:details]["Ship"]["ShipInvoiceNumber1"].gsub('-', '') : ''
				unless tracking.empty?
					unless yamato_numbers_list.include?(tracking)
						yahoo_shopping_data << [
							yahoo_shop_code,
							order[:order_id],
							reformat_date(order[:details]["OrderTime"]),
							"https://store.shopping.yahoo.co.jp/oystersisters/#{order[:details]["Item"]["ItemId"]}.html",
							order[:details]["Item"]["Quantity"],
							'10',
							order[:details]["Ship"]["ShipInvoiceNumber1"] ? order[:details]["Ship"]["ShipInvoiceNumber1"].gsub('-', '') : '',
							zip_code_length_fix(order[:details]["Ship"]["ShipZipCode"])
						]
						yamato_numbers_list << tracking
					end
				end
			end
		end	
		[['販売サイトコード', '注文番号', '販売日（注文日）', '商品コード', '注文個数', '配送事業者コード', '配送伝票番号', '配送先郵便番号']] + rakuten_data + funabiki_online_data + yahoo_shopping_data	
	end

end