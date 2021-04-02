module ManifestsHelper

	# Mainly used in Views
	
	def infomart_link(manifest)
		sales_date = manifest.sales_date
		scrape_date = DateTime.strptime(sales_date, '%Y年%m月%d日')
		start_date = (scrape_date - 1).strftime("%Y/%m/%d")
		end_date = (scrape_date + 2).strftime("%Y/%m/%d")
		'https://www2.infomart.co.jp/employment/shipping_list_window.page?6&st=0&parent=1&selbuy=0&op=00&f_date=' + start_date + '&t_date=' + end_date + '&stmnm&stmtel&HTradeState&resend&membersel=0&mcd_child&membernm&pdate=2&Infl=TC&TCalTradeState=0&TCalTradeState_2=0&TCalTradeState_3=0&TCalTradeState_4=0&TCalTradeState_5=0&TCalTradeState_6=0&TCalTradeState_7=1&TransitionPage_Cal=1&LeaveCond=1&perusal=0&cwflg=1'
	end

	def infomart_count(manifest)
		@infomart = Hash.new
		@manifest = manifest
		types = [:raw, :frozen]
		types.each do |t|
			i = 0
			manifest.infomart_orders[t].each do |order_id, order|
				if same_day(order) || fresh_order(order) || two_days(order)
					order[:items].each do |item_number, item_details|
						if item_details[:item_name].include? "殻付き生牡蠣"
							i += 1
						elsif item_details[:item_name].include? "坂越バラ牡蠣"
							i += 1
						elsif item_details[:item_name].include? "500g"
							i += 1
						elsif item_details[:item_name].include? "冷凍　殻付き牡蠣サムライオイスター"
							i += 1
						else
							i += item_details[:item_count].to_i
						end
					end
				end
			end
			@infomart[t] = i - 1
		end
		@infomart
	end

	def tsuhan_count(manifest)
		@tsuhan = Hash.new
		shipping_types = [:fridge, :frozen, :ebi, :anago]
		shipping_types.each do |st|
			@tsuhan[st] = 0
		end
		products = { :fridge => [437, 516, 517, 519, 520, 521, 838, 522, 837, 523, 583, 581, 580, 579, 578, 577, 584, 590, 591, 592, 593, 594], :frozen => [524, 645, 646], :ebi => [596, 595, 598, 599, 600, 597], :anago => [572, 575, 576] }
		types = [:raw, :frozen]
		types.each do |t|
			manifest.online_shop_orders[t].each do |order_number, order|
				order[:items].each do |item|
					products.each do |k, v|
						v.each do |t_id|
							if item["product_id"] == t_id
								@tsuhan[k] += 1
							end
						end
					end
				end
			end
		end
	end

	def today_warn(manifest)
		if manifest.sales_date == to_nengapi(Date.today) then true else false end
	end

	def non_zero_print(value)
		if value > 0 then '~ ' + value.to_s + ' 件' end
	end

	# Mainly Used in Controller

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

	def print_count(count)
		current = count.shift
		if current.is_a?(Integer) && current > 0
			current.to_s
		elsif current.is_a?(String)
			current
		end
	end

	def frozen_ids
		[524, 645, 646, 6554, 13585, 13552, 13551, 13584, 13583, 13582, 13580, 13579, 13577, 13586, 13587, 13588]
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

	def slash_date(nenngapi_date)
		if nenngapi_date.include?("年")
			DateTime.strptime(nenngapi_date, '%Y年%m月%d日').strftime("%Y/%m/%d")
		else
			DateTime.parse(nenngapi_date).strftime("%Y/%m/%d")
		end
	end

	def nengapi_to_gapi_date(nenngapi_date)
		DateTime.strptime(nenngapi_date, '%Y年%m月%d日').strftime("%m月%d日")
	end

	def nengapi_to_date(nenngapi_date)
		DateTime.strptime(nenngapi_date, '%Y年%m月%d日')
	end

	def unchecked_arrival_today
		date = (DateTime.strptime(@manifest.sales_date, '%Y年%m月%d日')).strftime("%Y/%m/%d")
		date
	end

	def unchecked_arrival_yeterday
		date = (DateTime.strptime(@manifest.sales_date, '%Y年%m月%d日')).strftime("%Y/%m/%d")
		date
	end

	def expected_arrival
		date = (DateTime.strptime(@manifest.sales_date, '%Y年%m月%d日') + 1).strftime("%Y/%m/%d")
		date
	end

	def two_day_arrival
		date = (DateTime.strptime(@manifest.sales_date, '%Y年%m月%d日') + 2).strftime("%Y/%m/%d")
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

	def fresh_order(order_details)
		if order_details[:fresh]
			( (unchecked_arrival_today == order_details[:arrival][/\d.*\/+\d./] || unchecked_arrival_yeterday == order_details[:arrival][/\d.*\/+\d./]) && order_details[:client].exclude?("ｏｃｅａｎ") && order_details[:client].exclude?("那覇") )
		else
			false
		end
	end

end
