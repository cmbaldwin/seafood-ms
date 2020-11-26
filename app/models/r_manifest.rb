class RManifest < ApplicationRecord

	attr_accessor :order_id
	attr_accessor :expense_name
	attr_accessor :purchaser
	attr_accessor :oysis
	attr_accessor :title
	attr_accessor :amount
	attr_accessor :options

	serialize :orders_hash
	serialize :new_orders_hash

	validates_presence_of :sales_date
	validates_uniqueness_of :sales_date

	include OrderQuery
	order_query :r_manifest_query,
		[:sales_date] # Sort :sales_date in :desc order
	
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

	def do_reciept
		self.options[:oysis].to_i.zero? ? oysis = false : oysis = true
		self.options[:order_id].empty? ? order = nil : order = self.new_orders_hash.reverse[options[:order_id].to_i]
		!order.nil? ? (remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first) : remarks = ''
		self.options[:title].nil? ? title = '様' : title = self.options[:title]
		self.options[:expense_name].empty? ? expense = 'お品代として' : expense = self.options[:expense_name]
		if self.options[:purchaser].empty?
			if order.nil?
				purchaser = ''
			else
				purchaser = order[:sender]["familyName"]
			end
		else
			purchaser = self.options[:purchaser]
		end
		if self.options[:amount].empty?
			if order.nil?
				amount = ''
			else
				amount = order[:final_cost]
			end
		else
			amount = self.options[:amount]
		end
		oyster_sisters_info = "株式会社船曳商店 　
		OYSTER SISTERS
		〒678-0232
		兵庫県赤穂市中広1576－11 
		TEL: 0791-42-3645 
		FAX: 0791-43-8151 
		店舗運営責任者: 船曳　晶子"
		company_info = "株式会社船曳商店 　
		〒678-0232
		兵庫県赤穂市中広1576－11 
		TEL: 0791-42-3645 
		FAX: 0791-43-8151
		メール: info@funabiki.info
		ウエブ: www.funabiki.info"
		oyster_sisters_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/Oyster%20Sisters%202.jpg")
		oysis_logo_cell = {image: oyster_sisters_logo, :scale => 0.08, colspan: 1, rowspan: 3, :position  => :center, :vposition => :center}
		funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")
		logo_cell = {:image => funabiki_logo, :scale => 0.05, colspan: 1, rowspan: 3, :position  => :center, :vposition => :center }
		receipt_date = self.options[:sales_date]

		# Make the PDF
		Prawn::Document.generate("PDF.pdf", page_size: "A5", :margin => [15]) do |pdf|
			pdf.font_families.update(PrawnPDF.fonts)
			
			#set utf-8 japanese font
			pdf.font "Takao"
			pdf.font_size 10
			pdf.move_down 10
			receipt_table = Array.new
			receipt_table << [{content: '   領   収   証   ', colspan: 3, size: 17, align: :center}]
			receipt_table << [{content: '<u>  ' + purchaser + '  ' + title + '  </u>' , colspan: 2, size: 14, align: :center}, {content: receipt_date, colspan: 1, size: 10, align: :center}]
			receipt_table << [{content: '★', size: 10, align: :center}, {content: '<font size="18">￥ ' + ApplicationController.helpers.yenify(amount) + '</font>', size: 10, align: :center}, {content: '★', size: 10, align: :center}]
			receipt_table << [{content: '但 ' + expense + '<br>上  記  正  に  領  収  い  た  し  ま  し  た', size: 10, align: :center, valign: :bottom, colspan: 3}]
			if oysis
				receipt_table << [{content: '内　　訳', colspan: 1}, oysis_logo_cell, {content: oyster_sisters_info, colspan: 1, rowspan: 3, size: 8}]
			else
				receipt_table << [{content: '内　　訳', colspan: 1}, logo_cell, {content: company_info, colspan: 1, rowspan: 3, size: 8}]
			end
			receipt_table << [{content: '税抜金額', colspan: 1}]
			receipt_table << [{content: '消費税額等（     ％）', colspan: 1}]

			2.times do |i|
				pdf.table(receipt_table, cell_style: {inline_format: true, valign: :center, padding: 10}, width: pdf.bounds.width, column_widths: {0..3 => (pdf.bounds.width/3)} ) do |t|
					t.cells.borders = [:top, :left, :right, :bottom]
					t.cells.border_width = 0
					t.row(0).border_top_width = 0.25
					t.row(-1).border_bottom_width = 0.25
					t.column(0).border_left_width = 0.25
					t.column(-1).border_right_width = 0.25

					t.row(1).border_top_width = 0.25
					t.row(1).border_bottom_width = 0.25
					t.row(2).border_bottom_width = 0.25
					t.row(2).border_lines = [:dotted, :solid, :dotted, :solid]
					t.row(1).border_lines = [:dotted, :solid, :dotted, :solid]

					t.row(2).background_color = 'EEEEEE'

					t.row(-2).column(0).border_bottom_width = 0.25
					t.row(-3).column(0).border_bottom_width = 0.25
					t.row(-2).column(0).border_lines = [:dotted, :solid, :dotted, :solid]
					t.row(-3).column(0).border_lines = [:dotted, :solid, :dotted, :solid]
				end
				i == 0 ? (pdf.move_down 40) : ()
			end
			oyster_sisters_logo.close
			funabiki_logo.close
			return pdf
		end
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
		self.new_orders_hash = orders_hash
		self.save
	end

	def do_seperated_pdf
		intital_data = self.new_orders_hash.reverse
		data = Hash.new
		knife_data = Hash.new
		order_types = [:mizukiri, :shells, :sets]
		other_types = [:dekapuri, :karaebi80g, :mukiebi80g, :anago, :reitou_shell, :tako, :kakita, :barakara]
		all_types = order_types.push(*other_types)
		intital_data.each_with_index do |order, i|
			(i == 0) ? data[:knife] = Hash.new : ()
			order_types.each do |t|
				(i == 0) ? (data[t] = Set.new) : ()
				if order[:knife][:count].empty?
					!order[t][:count].empty? ? data[t] << i : ()
				end
			end
			order_types.each do |t|
				(i == 0) ? (knife_data[t] = Set.new) : ()
				if !order[:knife][:count].empty?
					!order[t][:count].empty? ? knife_data[t] << i : ()
				end
			end
			other_types.each do |t|
				(i == 0) ? (data[t] = Set.new) : ()
				!order[t][:count].empty? ? data[t] << i : ()
			end
		end
		new_set = Hash.new
		new_knife = Hash.new	
		value_set = Hash.new
		knife_value_set = Hash.new
		final = Hash.new
		final_knife = Hash.new
		order_types.each do |t|
			new_set[t] = Hash.new
			new_knife[t] = Hash.new
			value_set[t] = Set.new
			knife_value_set[t] = Set.new
			if !data[t].empty?
				data[t].each do |n|
					if !intital_data[n][t][:count].empty?
						value_set[t] << intital_data[n][t][:amount]
						amount = intital_data[n][t][:amount]
						new_set[t][amount].nil? ? new_set[t][amount] = Array.new : ()
						new_set[t][amount] << n
					end
				end
			end
			if !knife_data[t].empty?
				knife_data[t].each do |n|
					if !intital_data[n][t][:count].empty?
						knife_value_set[t] << intital_data[n][t][:amount]
						amount = intital_data[n][t][:amount]
						new_knife[t][amount].nil? ? new_knife[t][amount] = Array.new : ()
						new_knife[t][amount] << n
					end
				end
			end
		end
		order_types.each do |t|
			final[t] = Array.new
			value_set[t].sort.reverse.each do |v|
				final[t].push(*new_set[t][v])
			end
			final_knife[t] = Array.new
			knife_value_set[t].sort.reverse.each do |v|
				final_knife[t].push(*new_knife[t][v])
			end
		end
		# 210mm x 297mm
		Prawn::Document.generate("PDF.pdf", :margin => [15]) do |pdf|
			pdf.font_families.update(PrawnPDF.fonts)
			#set utf-8 japanese font
			pdf.font "SourceHan", :style => :normal
			header_data_row = ['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']
			translation_hash = {:mizukiri => "水切り", :shells => "セル", :sets => "セット", :dekapuri => "デカプリオイスター", :karaebi80g => "干しエビ（殻付き）80g", :mukiebi80g => "干しエビ（むき身）80g", :anago => "穴子", :reitou_shell => "冷凍せ", :tako => "ボイルたこ (~1㎏)", :kakita => "カキータ", barakara: "小殻付き"}
			[final, final_knife].each_with_index do |data_set, mi|
				all_types.each_with_index do |type, i|
					if !data_set[type].empty? && !data_set[type].nil?
						(i != 0 || mi != 0) ? (pdf.start_new_page) : ()
						data_table = Array.new
						knife_text = (data_set == final_knife) ? ('+ ナイフ') : ('')
						data_table << [ {:content =>  "発送日:　<b>#{self.sales_date}</b>", :colspan => 5}, {:content => "商品区別:　<b>#{translation_hash[type] + knife_text}</b>", :colspan => 5}, {:content => "印刷日:　<b>#{DateTime.now.strftime("%Y年%m月%d日")}</b>", :colspan => 3}]
						data_table << header_data_row
						data_set[type].each do |local_order_number|
							order = intital_data[local_order_number]
							if order.is_a?(Hash)
								# make a new array for this order row
								order_data_row = Array.new
								# order numner
								order_data_row << (local_order_number + 1).to_s
								# sender and reciever
								sender_name = order[:sender]['familyName'].to_s + ' ' + order[:sender]['firstName'].to_s
								order_data_row << sender_name
								recipient_names = String.new
								order[:recipient].each do |recipient_name|
									if sender_name == recipient_name
										recipient_names << '""
										'
									else
										recipient_names << recipient_name + '
										'
									end
								end
								order_data_row << recipient_names
								#mizukiri
								if !order[:mizukiri][:amount].nil?
									text = ''
									order[:mizukiri][:amount].each_with_index do |amount, i|
										if i > 0 then text += '
											' end
										text += amount.to_s
										if order[:mizukiri][:count][i] > 1 then text += '× ' + order[:mizukiri][:count][i].to_s + '!' end
									end
									order_data_row << text
								end
								#shells
								if !order[:shells][:amount].nil?
									text = ''
									order[:shells][:amount].each_with_index do |amount, i|
										if i > 0 then text += '
											' end
										text += amount.to_s
										if order[:shells][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
									end
									order_data_row << text
								end
								#sets
								if !order[:sets][:amount].nil?
									text = ''
									order[:sets][:amount].each_with_index do |amount, i|
										if i > 0 then text += '
											' end
										text += '500g×' + amount.to_s.scan(/\d(?!.*\d)/).first + ' + ' + amount.to_s.scan(/\d{2}/).first + '個'
										if order[:sets][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
									end
									order_data_row << text
								end
								#others
								others_text = ''
									if !order[:tako][:amount].nil?
										order[:tako][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '
												' end
											others_text += 'ボイルたこ (~1㎏)×' + amount.to_s
											if order[:tako][:count][i] > 1 then others_text += '× ' + order[:tako][:count][i].to_s + '!' end
										end
									end
									if !order[:karaebi80g][:amount].nil?
										order[:karaebi80g][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '
												' end
											others_text += '干しエビ（殻付き）80g×' + amount.to_s
											if order[:karaebi80g][:count][i] > 1 then others_text += '× ' + order[:karaebi80g][:count][i].to_s + '!' end
										end
									end
									if !order[:mukiebi80g][:amount].nil?
										order[:mukiebi80g][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '
												' end
											others_text += '干しエビ（むき身）80g×' + amount.to_s
											if order[:mukiebi80g][:count][i] > 1 then others_text += '× ' + order[:mukiebi80g][:count][i].to_s + '!' end
										end
									end
									if !order[:anago][:amount].nil?
										order[:anago][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '
												' end
											others_text += '穴子' + amount.to_s + 'g'
											if order[:anago][:count][i] > 1 then others_text += '× ' + order[:anago][:count][i].to_s + '!' end
										end
									end
									if !order[:dekapuri][:amount].nil?
										order[:dekapuri][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '
												' end
											others_text += '冷凍500g×' + amount.to_s
											if order[:dekapuri][:count][i] > 1 then others_text += '× ' + order[:dekapuri][:count][i].to_s + '!' end
										end
									end
									if !order[:reitou_shell][:amount].nil?
										order[:reitou_shell][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '
												' end
											others_text += '冷凍セル' + amount.to_s + '個'
											if order[:reitou_shell][:count][i] > 1 then others_text += '× ' + order[:reitou_shell][:count][i].to_s + '!' end
										end
									end
									if !order[:kakita][:amount].nil?
										order[:kakita][:amount].each_with_index do |amount, i|
											if i > 0 then others_text += '  -
												' end
											others_text += 'カキータ×' + amount.to_s
											if order[:kakita][:count][i] > 1 then others_text += '× ' + order[:kakita][:count][i].to_s + '!' end
										end
									end
								order_data_row << others_text
								#arrival date
								def date_check(order)
									if (DateTime.strptime(self.sales_date, "%Y年%m月%d日") + 1) == (DateTime.strptime(order[:arrival_date], "%Y-%m-%d"))
										'明日着'
									else
										(DateTime.strptime(order[:arrival_date], "%Y-%m-%d")).strftime('%m月%d日')
									end
								end
								order_data_row << date_check(order)
								#arrival time
								order_data_row << if order[:arrival_time] == 'なし' then '' else order[:arrival_time] end
								#knife
								knife_count = 0
								if !order[:knife][:amount].nil?
									order[:knife][:amount].each_with_index do |amount, i|
										knife_count += order[:knife][:count][i]
									end
								end
								if knife_count > 1 then order_data_row << knife_count.to_s elsif knife_count > 0 then order_data_row << '✓' else order_data_row << '' end
								#noshi
								if order[:noshi] == true then order_data_row << '✓' else order_data_row << '' end
								#receipt
								remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first.gsub(/\n/, '')
								if order[:notes].nil? then notes = '' else notes = order[:notes] end
								if !order[:receipt].nil? then order_data_row << order[:receipt] elsif remarks.include?('領収') || notes.include?('領収') then order_data_row << '✓' else order_data_row << '' end
								#notes
								collect = (order[:payment_method] == "代金引換") ? '代引：￥' + order[:charged_cost].to_s : ''
								order_data_row << remarks + collect
								#add the array to the list of arrays that will become table rows
								data_table << order_data_row
							end
						end
						data_table << ['　'] * 13
						data_table << ['　'] * 13
						data_table << ['　'] * 13
						data_table << ['　'] * 13
						data_table << ['　'] * 13
						pdf.font_size 8
						pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :valign => :center, :inline_format => true}, :column_widths => {0 => 18, 1 => 55, 2 => 55, 3 => 25, 4 => 22, 5=> 50, 10 => 30, 11 => 30, 12=> 100}, :width => pdf.bounds.width ) do

							cells.row(0).padding = 7
							cells.column(0).rows(1..-1).padding = 2
							cells.columns(1..-1).rows(1..-1).padding = 4

							header_cells = cells.columns(0..12).rows(1)
							header_cells.background_color = "acacac"
							header_cells.size = 7
							header_cells.font_style = :bold

							cells.columns(7).rows(1..-1).font_style = :light

							set_other_time_cells = cells.columns([5, 6, 7, 8, 12]).rows(1..-1)
							set_other_time_cells.size = 7

							item_cells = cells.columns(3..6).rows(1..-1)
							multi_cells = item_cells.filter do |cell|
								cell.content.to_s[/!/]
							end
							multi_cells.background_color ="ffc48f"

							item_cells = cells.columns(9..11).rows(2..-6)
							check_cells = item_cells.filter do |cell|
								!cell.content.to_s.empty?
							end
							check_cells.background_color ="ffc48f"


							note_cells = cells.columns(12).rows(1..-1)
							cash_cells = note_cells.filter do |cell|
								cell.content.to_s[/代引/]
							end
							cash_cells.background_color ="ffc48f"

							date_cells = cells.columns(7).rows(1..-1)
							not_tomorrow_cells = date_cells.filter do |cell|
								cell.content.to_s[/月/]
							end
							not_tomorrow_cells.background_color ="ffc48f"
						end
					end
				end
			end
			#output the pdf
			return pdf
		end
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
		products = { mizukiri: { '10000003' => 4, '10000002' => 3, '10000001' => 2, '10000018' => 1, '10000035' => 2 },
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

	def do_new_pdf
		data = self.new_orders_hash.reverse
		# 210mm x 297mm
		Prawn::Document.generate("PDF.pdf", :margin => [15]) do |pdf|
			pdf.font_families.update(PrawnPDF.fonts)
			#set utf-8 japanese font
			pdf.font "SourceHan" 

			#print the date
			pdf.font_size 16
			pdf.font "SourceHan", :style => :bold
			pdf.text self.sales_date + "  楽天市場 発送表"
			pdf.move_down 15
			pdf.font "SourceHan", :style => :normal

			counts = self.new_order_counts
			work_totals = self.prep_work_totals
			counts_table = Array.new
			counts_table << ['むき身', 'セル', 'デカプリ', '冷凍セル', '穴子', 'タコ', '干しエビ', 'ナイフ']
			counts_table << [counts[:mizukiri].to_s + '　<font size="6">パック</font>', 
							"#{counts[:shells].to_s}　<font size='6'>個</font>　・　#{counts[:barakara].to_s}　<font size='6'>㎏</font>", 
							counts[:dekapuri].to_s + '　<font size="6">パック</font>', 
							counts[:reitou_shells].to_s + '　<font size="6">個</font>', 
							counts[:anago].to_s + '　<font size="6">件</font>', 
							counts[:tako].to_s + '　<font size="6">件</font>', 
							counts[:ebi].to_s + '　<font size="6">件</font>', 
							work_totals[:knife_count].to_s + '　<font size="6">個</font>']
			pdf.table( counts_table, :cell_style => {:inline_format => true, :border_width => 0.25, :valign => :center, :align => :center, :size => 10}, :width => pdf.bounds.width ) do |t|
				t.row(0).background_color = "acacac"
			end
			pdf.move_down 10

			#set up the data, make the header
			data_table = Array.new
			header_data_row = ['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']
			data_table << header_data_row

			data.each_with_index do |order, i|
				if order.is_a?(Hash)
					# make a new array for this order row
					order_data_row = Array.new
					# order numner
					order_data_row << i + 1
					# sender and reciever
					sender_name = order[:sender]['familyName'].to_s + ' ' + order[:sender]['firstName'].to_s
					order_data_row << sender_name
					recipient_names = String.new
					order[:recipient].each do |recipient_name|
						if sender_name == recipient_name
							recipient_names << '""
							'
						else
							recipient_names << recipient_name + '
							'
						end
					end
					order_data_row << recipient_names
					#mizukiri
					if !order[:mizukiri][:amount].nil?
						text = ''
						order[:mizukiri][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
							 ' end
							text += amount.to_s
							if order[:mizukiri][:count][i] > 1 then text += '× ' + order[:mizukiri][:count][i].to_s + '!' end
						end
						order_data_row << text
					end
					#shells
					if !order[:shells][:amount].nil? && !order[:barakara][:amount].nil?
						text = ''
						order[:shells][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
								' end
							text += "#{amount.to_s}#{'個' if !order[:barakara][:amount].nil?} "
							if order[:shells][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
						end
						order[:barakara][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
								' end
							text += "#{amount.to_s}㎏ "
							if order[:barakara][:count][i] > 1 then text += '× ' + order[:barakara][:count][i].to_s + '!' end
						end
						order_data_row << text
					end
					#sets
					if !order[:sets][:amount].nil?
						text = ''
						order[:sets][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
								' end
							text += '500g×' + amount.to_s.scan(/\d(?!.*\d)/).first + ' + ' + amount.to_s.scan(/\d{2}/).first + '個'
							if order[:sets][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
						end
						order_data_row << text
					end
					#others
					others_text = ''
						if !order[:tako][:amount].nil?
							order[:tako][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += 'ボイルたこ (~1㎏)' + amount.to_s
								if order[:tako][:count][i] > 1 then others_text += '× ' + order[:tako][:count][i].to_s + '!' end
							end
						end
						if !order[:karaebi80g][:amount].nil?
							order[:karaebi80g][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '干しエビ（殻付き）80g×' + amount.to_s
								if order[:karaebi80g][:count][i] > 1 then others_text += '× ' + order[:karaebi80g][:count][i].to_s + '!' end
							end
						end
						if !order[:mukiebi80g][:amount].nil?
							order[:mukiebi80g][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '干しエビ（むき身）80g×' + amount.to_s
								if order[:mukiebi80g][:count][i] > 1 then others_text += '× ' + order[:mukiebi80g][:count][i].to_s + '!' end
							end
						end
						if !order[:anago][:amount].nil?
							order[:anago][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '穴子' + amount.to_s + 'g'
								if order[:anago][:count][i] > 1 then others_text += '× ' + order[:anago][:count][i].to_s + '!' end
							end
						end
						if !order[:dekapuri][:amount].nil?
							order[:dekapuri][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '冷凍500g×' + amount.to_s
								if order[:dekapuri][:count][i] > 1 then others_text += '× ' + order[:dekapuri][:count][i].to_s + '!' end
							end
						end
						if !order[:reitou_shell][:amount].nil?
							order[:reitou_shell][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '冷凍セル' + amount.to_s + '個'
								if order[:reitou_shell][:count][i] > 1 then others_text += '× ' + order[:reitou_shell][:count][i].to_s + '!' end
							end
						end
						if !order[:kakita][:amount].nil?
							order[:kakita][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += 'カキータ×' + amount.to_s
								if order[:kakita][:count][i] > 1 then others_text += '× ' + order[:kakita][:count][i].to_s + '!' end
							end
						end
					order_data_row << others_text
					#arrival date
					def date_check(order)
						if (DateTime.strptime(self.sales_date, "%Y年%m月%d日") + 1) == (DateTime.strptime(order[:arrival_date], "%Y-%m-%d"))
							'明日着'
						else
							(DateTime.strptime(order[:arrival_date], "%Y-%m-%d")).strftime('%m月%d日')
						end
					end
					order_data_row << date_check(order)
					#arrival time
					order_data_row << if order[:arrival_time] == 'なし' then '' else order[:arrival_time] end
					#knife
					knife_count = 0
					if !order[:knife][:amount].nil?
						order[:knife][:amount].each_with_index do |amount, i|
							knife_count += order[:knife][:count][i]
						end
					end
					if knife_count > 1 then order_data_row << knife_count.to_s elsif knife_count > 0 then order_data_row << '✓' else order_data_row << '' end
					#noshi
					if order[:noshi] == true then order_data_row << '✓' else order_data_row << '' end
					#receipt
					remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first.gsub(/\n/, '')
					if order[:notes].nil? then notes = '' else notes = order[:notes] end
					if !order[:receipt].nil? then order_data_row << order[:receipt] elsif remarks.include?('領収') || notes.include?('領収') then order_data_row << '✓' else order_data_row << '' end
					#notes
					collect = (order[:payment_method] == "代金引換") ? '代引：￥' + order[:charged_cost].to_s : ''
					order_data_row << remarks + collect
					#add the array to the list of arrays that will become table rows
					data_table << order_data_row
				end
			end

			data_table << ['　'] * 13
			data_table << ['　'] * 13
			data_table << ['　'] * 13
			data_table << ['　'] * 13
			data_table << ['　'] * 13
			pdf.font_size 8
			pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :valign => :center}, :column_widths => {0 => 18, 1 => 55, 2 => 55, 3 => 30, 4 => 27, 5=> 50, 12=> 100}, :width => pdf.bounds.width ) do
			
				cells.column(0).rows(1..-1).padding = 2
				cells.columns(1..-1).rows(1..-1).padding = 4

				header_cells = cells.columns(0..12).rows(0)
				header_cells.background_color = "acacac"
				header_cells.size = 7
				header_cells.font_style = :bold

				cells.columns(7).rows(1..-1).font_style = :light

				set_other_time_cells = cells.columns([5, 6, 7, 8, 12]).rows(1..-1)
				set_other_time_cells.size = 7

				item_cells = cells.columns(3..6).rows(1..-1)
				multi_cells = item_cells.filter do |cell|
					cell.content.to_s[/!/]
				end
				multi_cells.background_color ="ffc48f"

				item_cells = cells.columns(9..11).rows(1..-6)
				check_cells = item_cells.filter do |cell|
					!cell.content.to_s.empty?
				end
				check_cells.background_color ="ffc48f"


				note_cells = cells.columns(12).rows(1..-1)
				cash_cells = note_cells.filter do |cell|
					cell.content.to_s[/代引/]
				end
				cash_cells.background_color ="ffc48f"

				date_cells = cells.columns(7).rows(1..-1)
				not_tomorrow_cells = date_cells.filter do |cell|
					cell.content.to_s[/月/]
				end
				not_tomorrow_cells.background_color ="ffc48f"
			end

			#output pdf
			return pdf
		end
	end

end