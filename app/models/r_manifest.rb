class RManifest < ApplicationRecord

	serialize :orders_hash
	serialize :new_orders_hash

	validates_presence_of :sales_date
	validates_uniqueness_of :sales_date

	include OrderQuery
	order_query :r_manifest_query,
		[:sales_date] # Sort :sales_date in :desc order

	def date
		DateTime.strptime(self.sales_date, "%Y年%m月%d日")
	end

	def order_addresses(order)
		order[:raw_data]["PackageModelList"].map do |pkg|
			{zip: pkg["SenderModel"].values[0..1].join,
			prefecture: pkg["SenderModel"].values[2],
			city: pkg["SenderModel"].values[3],
			address: pkg["SenderModel"].values[4],
			last_name: pkg["SenderModel"].values[5],
			first_name: pkg["SenderModel"].values[6],
			katakana_last_name: pkg["SenderModel"].values[7],
			katakana_first_name: pkg["SenderModel"].values[8],
			phone: pkg["SenderModel"].values[9..12].join,
			item_id: pkg["ItemModelList"].map{ |item| item["itemId"]}}
		end
	end

	def item_id_to_yamato_box_size(item_id)
		{
			'10000018' => 80, #m1
			'10000001' => 80, #m2
			'10000035' => 80, #tm2
			'10000002' => 100, #m3
			'10000003' => 100, #m4
			'10000027' => 80, #p1
			'10000030' => 80, #p2
			'10000028' => 80, #p3
			'10000029' => 100, #p4
			'10000015' => 60, #k10
			'10000004' => 80, #k20
			'10000005' => 80, #k30
			'10000025' => 80, #k40
			'10000006' => 100, #k50
			'10000040' => 100, #k100
			'10000031' => 60, #pk10
			'10000037' => 80, #pk20
			'10000038' => 80, #pk30
			'10000039' => 80, #pk40
			'10000041' => 100, #pk50
			'10000042' => 100, #pk100
			'10000007' => 80, #s110
			'10000008' => 80, #s120
			'10000022' => 100, #s130
			'10000009' => 100, #s220
			'10000023' => 100, #s230
			'boiltako800-1k' => 80, #tako
			'10000012' => 60, #a350
			'10000013' => 60, #a480
			'10000014' => 60, #a560
			'10000017' => 60, #em1
			'10000016' => 60, #em2
			'10000010' => 60, #kem1
			'10000011' => 60, #kem2
			'barakaki_1k' => 60, #bkar1
			'barakaki_2k' => 80, #bkar1
			'barakaki_3k' => 80, #bkar1
			'barakaki_5k' => 80 #bkar1
		}[item_id]
	end

	def rakuten_rate
		0.12
	end

	def item_expenses(item_id)
		{
			'10000018' => 250, #m1
			'10000001' => 310, #m2
			'10000035' => 310, #tm2
			'10000002' => 425, #m3
			'10000003' => 490, #m4
			'10000027' => 205, #p1
			'10000030' => 230, #p2
			'10000028' => 255, #p3
			'10000029' => 330, #p4
			'10000015' => 150, #k10
			'10000004' => 180, #k20
			'10000005' => 180, #k30
			'10000025' => 230, #k40
			'10000006' => 250, #k50
			'10000040' => 280, #k100
			'10000031' => 150, #pk10
			'10000037' => 180, #pk20
			'10000038' => 180, #pk30
			'10000039' => 230, #pk40
			'10000041' => 250, #pk50
			'10000042' => 280, #pk100
			'10000007' => 250, #s110
			'10000008' => 250, #s120
			'10000022' => 300, #s130
			'10000009' => 360, #s220
			'10000023' => 360, #s230
			'boiltako800-1k' => 180, #tako
			'10000012' => 300, #a350
			'10000013' => 300, #a480
			'10000014' => 400, #a560
			'10000017' => 300, #em1
			'10000016' => 300, #em2
			'10000010' => 300, #kem1
			'10000011' => 300, #kem2
			'barakaki_1k' => 150, #bkar1
			'barakaki_2k' => 150, #bkar1
			'barakaki_3k' => 200, #bkar1
			'barakaki_5k' => 200 #bkar1
		}[item_id]
	end

	def item_raw_usage(item_id)
		{ # [nama_muki, nama_kara, p_muki, p_kara, anago, mebi, kebi, tako, barakara ]
			'10000018' => [1, 0, 0, 0, 0, 0, 0, 0, 0], #m1
			'10000001' => [2, 0, 0, 0, 0, 0, 0, 0, 0], #m2
			'10000035' => [2, 0, 0, 0, 0, 0, 0, 0, 0], #tm2
			'10000002' => [3, 0, 0, 0, 0, 0, 0, 0, 0], #m3
			'10000003' => [4, 0, 0, 0, 0, 0, 0, 0, 0], #m4
			'10000027' => [0, 0, 1, 0, 0, 0, 0, 0, 0], #p1
			'10000030' => [0, 0, 2, 0, 0, 0, 0, 0, 0], #p2
			'10000028' => [0, 0, 3, 0, 0, 0, 0, 0, 0], #p3
			'10000029' => [0, 0, 4, 0, 0, 0, 0, 0, 0], #p4
			'10000026' => [0, 10, 0, 0, 0, 0, 0, 0, 0], #k10
			'10000015' => [0, 10, 0, 0, 0, 0, 0, 0, 0], #k10
			'10000004' => [0, 20, 0, 0, 0, 0, 0, 0, 0], #k20
			'10000005' => [0, 30, 0, 0, 0, 0, 0, 0, 0], #k30
			'10000025' => [0, 40, 0, 0, 0, 0, 0, 0, 0], #k40
			'10000006' => [0, 50, 0, 0, 0, 0, 0, 0, 0], #k50
			'10000040' => [0, 100, 0, 0, 0, 0, 0, 0, 0], #k100
			'10000031' => [0, 0, 0, 10, 0, 0, 0, 0, 0], #pk10
			'10000037' => [0, 0, 0, 20, 0, 0, 0, 0, 0], #pk20
			'10000038' => [0, 0, 0, 30, 0, 0, 0, 0, 0], #pk30
			'10000039' => [0, 0, 0, 40, 0, 0, 0, 0, 0], #pk40
			'10000041' => [0, 0, 0, 50, 0, 0, 0, 0, 0], #pk50
			'10000042' => [0, 0, 0, 100, 0, 0, 0, 0, 0], #pk100
			'10000007' => [1, 10, 0, 0, 0, 0, 0, 0, 0], #s110
			'10000008' => [1, 20, 0, 0, 0, 0, 0, 0, 0], #s120
			'10000022' => [1, 30, 0, 0, 0, 0, 0, 0, 0], #s130
			'10000009' => [2, 20, 0, 0, 0, 0, 0, 0, 0], #s220
			'10000023' => [2, 30, 0, 0, 0, 0, 0, 0, 0], #s230
			'10000012' => [0, 0, 0, 0, 0.350, 0, 0, 0, 0], #a350
			'10000013' => [0, 0, 0, 0, 0.480, 0, 0, 0, 0], #a480
			'10000014' => [0, 0, 0, 0, 0.560, 0, 0, 0, 0], #a560
			'10000017' => [0, 0, 0, 0, 0, 0.400, 0, 0, 0], #em1
			'10000016' => [0, 0, 0, 0, 0, 0.240, 0, 0, 0], #em2
			'10000010' => [0, 0, 0, 0, 0, 0, 0.400, 0, 0], #kem1
			'10000011' => [0, 0, 0, 0, 0, 0, 0.800, 0, 0], #kem2
			'barakaki_1k' => [0, 0, 0, 0, 0, 0, 0, 0, 1], #bkar1
			'barakaki_2k' => [0, 0, 0, 0, 0, 0, 0, 0, 2], #bkar1
			'barakaki_3k' => [0, 0, 0, 0, 0, 0, 0, 0, 3], #bkar1
			'barakaki_5k' => [0, 0, 0, 0, 0, 0, 0, 0, 5], #bkar1
			'boiltako800-1k' => [0, 0, 0, 0, 0, 0, 0, 1, 0] #tako
		}[item_id]
	end

	def raw_oyster_costs
		supply = OysterSupply.find_by(supply_date: self.sales_date)
		if supply
			mukimi_avg_cost = supply.totals[:sakoshi_avg_kilo].to_i
			shell_avg_cost = supply.totals[:big_shell_avg_cost].to_i
		else
			mukimi_avg_cost = 1000 #default kilo cost
			shell_avg_cost = 45 #default shell cost
		end
		#hard coding a lot of the raw material cost estimates. shufunomise anago is about 4600 ffr
		{nama_muki: mukimi_avg_cost, nama_kara: shell_avg_cost, p_muki: 500, p_kara: 45, anago: 6000, mebi: 4600, kebi: 2200, tako: 2200, bara: 400 }
	end

	def get_raw_costs(order)
		cost = 0
		costs = raw_oyster_costs.values
		order_addresses(order).map{|pkg| pkg[:item_id].flatten }.flatten.compact.each do |item_id|
			item_raw_usage(item_id.to_s).each_with_index do |count, i|
				cost += (count * costs[i]) unless costs[i].nil?
			end
		end
		cost
	end

	def get_profits(order)
		get_sales(order) - get_total_costs(order) - get_raw_costs(order)
	end

	def get_subtotal_without_raw(order)
		get_sales(order) - get_total_costs(order)
	end

	def without_raw_subtotal
		self.new_orders_hash.inject(0){|memo, order| memo += get_subtotal_without_raw(order) }
	end

	def total_profits
		self.new_orders_hash.inject(0){|memo, order| memo += get_profits(order) }
	end

	def get_sales(order)
		order[:raw_data]["totalPrice"]
	end

	def get_shipping(order)
		order_addresses(order).inject(0) do |memo, address_hash|
			memo += calculate_shipping(address_hash[:prefecture], address_hash[:city], address_hash[:item_id].map{|id| item_id_to_yamato_box_size(id.to_s)})
		end
	end

	def get_expenses(order)
		order_addresses(order).map{|address_hash| address_hash[:item_id] }.flatten.map{|item_id| item_expenses(item_id.to_s) }.compact.inject(0, :+)
	end

	def get_total_costs(order)
		get_shipping(order) + get_expenses(order)
	end

	def get_all_costs
		self.new_orders_hash.inject(0){|memo, order| memo += get_total_costs(order)}
	end

	def get_order_details_by_api
		require 'httparty'
		require 'json'

		# https://webservice.rms.rakuten.co.jp/merchant-portal/view?contents=/ja/common/1-1_service_index/rmsWebServiceAuthentication
		# serviceSecret=aaa, licenseKey=bbb　の場合、aaa:bbbをBase64エンコードした値(YWFhOmJiYg==)を利用して、以下の情報を認証情報に設定します。 ESA YWFhOmJiYg==
		# Base64.encode64(x + ":"  + y) then remove the \n (there should be two)
		authorization = 'ESA ' + ENV['RAKUTEN_API']
		sales_date = self.sales_date
		start_date_time = DateTime.strptime(sales_date, "%Y年%m月%d日").strftime('%Y-%m-%dT%H:%M:%S') + '+0900'
		end_date_time = (DateTime.strptime(sales_date, "%Y年%m月%d日") + 23.hours + 59.minutes + 59.seconds).strftime('%Y-%m-%dT%H:%M:%S') + '+0900'


		get_orders_list = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/searchOrder/",
			:headers => { "Authorization" => authorization,
				"Content-Type" => "application/json; charset=utf-8"},
			:body => {
				"dateType" => 4,
				"startDatetime" => start_date_time,
				"endDatetime" => end_date_time,
				"PaginationRequestModel" => {
					"requestRecordsAmount" => 1000,
					"requestPage" => 1,
					"SortModelList" => [{
						"sortColumn" => 1,
						"sortDirection" => 1 }]
			}}.to_json)
		if get_orders_list['orderNumberList'].length > 100
			orders_list_by_100 = get_orders_list['orderNumberList'].each_slice(100).to_a
			order_details = Array.new
			messages = Array.new
			orders_list_by_100.each do |sub_list|
				get_order_details = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/getOrder/",
					:headers => { "Authorization" => authorization,
						"Content-Type" => "application/json; charset=utf-8"},
					:body => {"orderNumberList" => sub_list}.to_json)
				order_details << get_order_details["OrderModelList"]
				messages << get_order_details["MessageModelList"]
			end
		else
			get_order_details = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/getOrder/",
				:headers => { "Authorization" => authorization,
					"Content-Type" => "application/json; charset=utf-8"},
				:body => {"orderNumberList" => get_orders_list['orderNumberList']}.to_json)
			order_details = get_order_details["OrderModelList"]
			messages = get_order_details["MessageModelList"]
		end
		orders_hash = Array.new
		order_details.flatten.each_with_index do |order, i|
			if !order.nil?
				unless order["orderProgress"] == 900
					orders_hash[i] = Hash.new
					orders_hash[i][:order_number] = order['orderNumber']
					orders_hash[i][:order_date] = order['orderDatetime']
					orders_hash[i][:asuraku] = order['asurakuFlag']
					orders_hash[i][:payment_method] = order['SettlementModel']['settlementMethod']
					orders_hash[i][:final_cost] = order['totalPrice']
					orders_hash[i][:charged_cost] = order['requestPrice']
					orders_hash[i][:sender] = order['OrdererModel']
					orders_hash[i][:items] = Array.new
					orders_hash[i][:recipient] = Array.new
					order['PackageModelList'].each do |package_model|
						last_name = package_model['SenderModel']['familyName']
						first_name = package_model['SenderModel']['firstName']
						orders_hash[i][:recipient] << (!last_name.nil? ? last_name : '') + ' ' + (!first_name.nil? ? first_name : '')
						package_model['ItemModelList'].each do |item|
							orders_hash[i][:items] << item
						end
					end
					types = ['mizukiri', 'shells', 'barakara', 'sets', 'karaebi80g', 'mukiebi80g', 'anago', 'dekapuri', 'reitou_shell', 'kakita', 'tako', 'knife']
					types.each do |type|
						orders_hash[i][type.to_sym] = Hash.new
						orders_hash[i][type.to_sym][:amount] = Array.new
						orders_hash[i][type.to_sym][:count] = Array.new
					end
					products = { mizukiri: { '10000003' => 4, '10000002' => 3, '10000001' => 2, '10000018' => 1, '10000035' => 2 },
						sets: { '10000007' => 101, '10000008' => 201, '10000022' => 301, '10000009' => 202, '10000023' => 302 },
						shells: { '10000040' => 100, '10000006' => 50, '10000025' => 40, '10000005' => 30, '10000004' => 20, '10000015' => 10 },
						karaebi80g: { '10000011' => 10, '10000010' => 5 },
						mukiebi80g: { '10000016' => 3, '10000017' => 5 },
						anago: { '10000012' => 350, '10000013' => 480, '10000014' => 600 },
						dekapuri: { '10000027' => 1, '10000030' => 2, '10000028' => 3, '10000029' => 4 },
						tako: { 'boiltako800-1k' => 1},
						reitou_shell: { '10000042' => 100, '10000041' => 50, '10000039' => 40, '10000038' => 30, '10000037' => 20, '10000031' => 10 },
						barakara: { 'barakaki_1k' => 1, 'barakaki_2k' => 2, 'barakaki_3k' => 3, 'barakaki_5k' => 5 }
						}
					orders_hash[i][:items].each do |item_details_hash|
						products.each do |type, id_hash|
							id_hash.each do |id, amount|
								if item_details_hash['manageNumber'] == id
									orders_hash[i][type][:amount] << amount
									orders_hash[i][type][:count] << item_details_hash['units']
								end
							end
						end
						if !item_details_hash['selectedChoice'].nil?
							if item_details_hash['selectedChoice'].include?('希望する')
								orders_hash[i][:knife][:amount] << 1
								orders_hash[i][:knife][:count] << 1
								orders_hash[i][:knife][:added] = false
								if !order['WrappingModel1'].nil?
									if order['WrappingModel1']['name'].include?('ナイフ')
										orders_hash[i][:knife][:added] = true
									end
								elsif !order['WrappingModel2'].nil?
									if order['WrappingModel2']['name'].include?('ナイフ')
										orders_hash[i][:knife][:added] = true
									end
								end
							elsif item_details_hash['selectedChoice'].include?('付ける')
								orders_hash[i][:kakita][:amount] << 1
								orders_hash[i][:kakita][:count] << 1
								orders_hash[i][:kakita][:added] = false
								if !order['WrappingModel1'].nil?
									if order['WrappingModel1']['name'].include?('カキータ')
										orders_hash[i][:kakita][:added] = true
									end
								elsif !order['WrappingModel2'].nil?
									if order['WrappingModel2']['name'].include?('カキータ')
										orders_hash[i][:kakita][:added] = true
									end
								end
							end
						end
					end
					orders_hash[i][:shipping_date] = Array.new
					orders_hash[i][:yamato_numbers] = Array.new
					order['PackageModelList'][0]['ShippingModelList'].each do |shipment|
						orders_hash[i][:shipping_date] << shipment['shippingDate']
						orders_hash[i][:yamato_numbers] << shipment['shippingNumber']
					end
					orders_hash[i][:arrival_date] = order['deliveryDate']
					arrival_options = { 0 => 'なし', 1 => '午前', 2 => '午後', 1416 => '14~16時', 1618 => '16~18時', 1820 => '18~20時', 1921 => '19~21時' }
					orders_hash[i][:arrival_time] = arrival_options[order['shippingTerm']]
					orders_hash[i][:noshi] = if order['PackageModelList'][0]['noshi'].nil? then false else true end
					if order['remarks'].include?('領収書をメール')
						orders_hash[i][:receipt] = 'メール'
					elsif order['remarks'].include?('領収書を同梱')
						orders_hash[i][:receipt] = '同梱'
					else
						orders_hash[i][:receipt] = nil
					end
					orders_hash[i][:remarks] = order['remarks']
					orders_hash[i][:notes] = order['memo']
					orders_hash[i][:raw_data] = order
				end
			end
		end
		self.new_orders_hash = orders_hash.compact
		self.save
	end

	def new_order_counts
		counts = Hash.new
		mizukiri_count = 0
		shells_count = 0
		dekapuri_count = 0
		reitou_shell_count = 0
		anago_count = 0
		ebi_count = 0
		bara_count = 0
		tako_count = 0
		if !self.new_orders_hash.nil?
			self.new_orders_hash.each do |order|
				if order.is_a?(Hash)
					order[:noshi] ? (counts[:noshi] = true) : ()
					order[:receipt] ? (counts[:receipt] = true) : ()
					if !order[:mizukiri].empty?
						order[:mizukiri][:amount].each_with_index do |amount, i|
							mizukiri_count += (amount * order[:mizukiri][:count][i])
						end
					end
					if !order[:shells].empty?
						order[:shells][:amount].each_with_index do |amount, i|
							shells_count += (amount * order[:shells][:count][i])
						end
					end
					if !order[:barakara].empty?
						order[:barakara][:amount].each_with_index do |amount, i|
							bara_count += (amount * order[:barakara][:count][i])
						end
					end
					if !order[:sets].empty?
						order[:sets][:amount].each_with_index do |amount, i|
							mizukiri_count += (amount.to_s.scan(/\d(?!.*\d)/).first.to_i * order[:sets][:count][i])
							shells_count += (amount.to_s.scan(/\d{2}/).first.to_i * order[:sets][:count][i])
						end
					end
					if !order[:dekapuri].empty?
						order[:dekapuri][:amount].each_with_index do |amount, i|
							dekapuri_count += (amount * order[:dekapuri][:count][i])
						end
					end
					if !order[:reitou_shell].empty?
						order[:reitou_shell][:amount].each_with_index do |amount, i|
							reitou_shell_count += (amount * order[:reitou_shell][:count][i])
						end
					end
					if !order[:anago].empty?
						order[:anago][:amount].each_with_index do |amount, i|
							anago_count += 1
						end
					end
					if !order[:karaebi80g].empty?
						order[:karaebi80g][:amount].each_with_index do |amount, i|
							ebi_count += 1
						end
					end
					if !order[:mukiebi80g].empty?
						order[:mukiebi80g][:amount].each_with_index do |amount, i|
							ebi_count += 1
						end
					end
					unless order[:tako].nil?
						if !order[:tako].empty?
							order[:tako][:amount].each_with_index do |amount, i|
								tako_count += 1
							end

						end
					end
				end
			end
		end
		counts[:mizukiri] = mizukiri_count
		counts[:shells] = shells_count
		counts[:dekapuri] = dekapuri_count
		counts[:reitou_shells] = reitou_shell_count
		counts[:anago] = anago_count
		counts[:ebi] = ebi_count
		counts[:tako] = tako_count
		counts[:barakara] = bara_count
		counts
	end

	def prep_work_totals
		products = { 
			mizukiri: { '10000003' => 4, '10000002' => 3, '10000001' => 2, '10000018' => 1, '10000035' => 2 },
			sets: { '10000007' => 101, '10000008' => 201, '10000022' => 301, '10000009' => 202, '10000023' => 302 },
			shells: { '10000040' => 100, '10000006' => 50, '10000025' => 40, '10000005' => 30, '10000004' => 20, '10000015' => 10 },
			karaebi80g: { '10000011' => 10, '10000010' => 5 },
			mukiebi80g: { '10000016' => 3, '10000010' => 5 },
			anago: { '10000012' => 350, '10000013' => 480, '10000014' => 600 },
			dekapuri: { '10000027' => 1, '10000030' => 2, '10000028' => 3, '10000029' => 4 },
			tako: { 'boiltako800-1k' => 1},
			reitou_shell: { '10000042' => 100, '10000041' => 50, '10000039' => 40, '10000038' => 30, '10000037' => 20, '10000031' => 10 },
			barakara: { 'barakaki_1k' => 1, 'barakaki_2k' => 2, 'barakaki_3k' => 3, 'barakaki_5k' => 5 }
		}
		work_totals = Hash.new
		work_totals[:knife_count] = 0
				self.new_orders_hash.reverse.each do |order|
			order[:raw_data]["PackageModelList"].each do |package|
				package["ItemModelList"].each do |item|
					if item["selectedChoice"]
						item["selectedChoice"].include?('牡蠣ナイフ・軍手片方セット:希望する') ? (work_totals[:knife_count] += 1) : ()
					end
					products.each do |type, check_hash|
						work_totals[type] = Array.new if work_totals[type].nil?
						check_hash[item["manageNumber"]] ? (work_totals[type] << check_hash[item["manageNumber"]]) : ()
					end
				end
			end
		end
		work_totals[:product_counts] = Hash.new
		products.keys.each do |type|
			if !work_totals[type].nil?
				work_totals[:product_counts][type] = work_totals[type].group_by(&:itself).map { |k,v| [k, v.length] }.to_h
			else
				work_totals[:product_counts][type] = {}
			end
		end
		work_totals[:shell_cards] = 0
		work_totals[:shell_cards] += work_totals[:sets] ? work_totals[:sets].length : 0
		work_totals[:shell_cards] += work_totals[:shells] ? work_totals[:shells].length : 0
		work_totals[:shell_cards] += work_totals[:barakara] ? work_totals[:barakara].length : 0
		work_totals
	end

end
