class InfomartAPI
	require 'mechanize'
	require 'csv'

	# Acquire Data from the Infomart system
	# CSV Data Reference
	# [
	#     [ 0] "［データ区分］", #  H = Header, D = Data, F = Footer
	#     [ 1] "［伝票日付］",
	#     [ 2] "［伝票No］",
	#     [ 3] "［取引状態］",
	#     [ 4] "［自社コード］",
	#     [ 5] "［自社会員名］",
	#     [ 6] "［自社担当者］",
	#     [ 7] "［取引先コード］",
	#     [ 8] "［取引先名］",
	#     [ 9] "［納品場所コード］",
	#     [10] "［納品場所名］",
	#     [11] "［納品場所 住所］",
	#     [12] "［マイカタログID］",
	#     [13] "［自社管理商品コード］",
	#     [14] "［商品名］",
	#     [15] "［規格］",
	#     [16] "［入数］",
	#     [17] "［入数単位］",
	#     [18] "［単価］",
	#     [19] "［数量］",
	#     [20] "［単位］",
	#     [21] "［金額］",
	#     [22] "［消費税］",
	#     [23] "［小計］",
	#     [24] "［課税区分］",
	#     [25] "［税区分］",
	#     [26] "［合計 商品本体］",
	#     [27] "［合計 商品消費税］",
	#     [28] "［合計 送料本体］",
	#     [29] "［合計 送料消費税］",
	#     [30] "［合計 その他］",
	#     [31] "［総合計］",
	#     [32] "［発注日］",
	#     [33] "［発送日］",
	#     [34] "［納品日］",
	#     [35] "［受領日］",
	#     [36] "［取引ID_SYSTEM］",
	#     [37] "［伝票明細ID_SYSTEM］",
	#     [38] "［発注送信日］",
	#     [39] "［発注送信時間］",
	#     [40] "［送信日］",
	#     [41] "［送信時間］"
	# ]

	def initialize(date = Date.today)
		@date = date
	end

	def date
		@date
	end

	def parse_csv_date(date_str)
		date_str.empty? ? nil : Date.strptime(date_str, "%Y/%m/%d") 
	end

	def assign_order_attribues(order, row)
		order.csv_data[row[37]] = row.map{|i| i.to_s }
		items_hash = order.items
		items_hash[row[37]] = {
			item_id: row[12],
			item_code: row[13],
			name: row[14], 
			standard: row[15],
			in_box_quantity: row[16],
			in_box_counter: row[17],
			price: row[18],
			quantity: row[19],
			counter: row[20],
			item_subtotal: row[21],
			tax: row[22],
			subtotal: row[23],
			tax_rate: row[24],
			tax_category: row[25],
			all_item_total: row[26],
			all_item_tax: row[27],
			all_item_shipping: row[28],
			all_item_shipping_tax: row[29],
			other_total: row[30],
			order_total: row[31],
			transaction_id: row[36]
		}
		order.assign_attributes({ 
			order_time: DateTime.parse("#{row[40]} #{row[41]} +0900") , 
			status: row[3],
			destination: row[8],
			ship_date: parse_csv_date(row[33]), 
			arrival_date: parse_csv_date(row[34]), 
			items: items_hash, 
			address: row[11]
		})
		order.save
	end

	def process_csv(csv, existing_updated, newly_created)
		CSV.foreach(csv, encoding: 'Shift_JIS:UTF-8').with_index do |row, i|
			@csv_date = row[1] if i == 0
			if (i >= 1) && (row[0] == "D")
				order = InfomartOrder.find_by(order_id: row[2])
				if order
					existing_updated << order
				else
					order = InfomartOrder.new(
						order_id: row[2], 
						items: Hash.new,
						csv_data: Hash.new
					)
					newly_created << order
				end
				assign_order_attribues(order, row)
			end
		end
	end

	def acquire_new_data(acquisition_method = :mechanize, data = nil)
		if acquisition_method == :mechanize
			puts "Attemping to download CSV data via Mechanize."
			agent = Mechanize.new
			page = agent.get('https://www2.infomart.co.jp/trade/download/bat_detail.pagex?4')
			login_form = page.form
			#login first screen
			login_form.UID = ENV['INFOMART_LOGIN']
			login_form.PWD = ENV['INFOMART_PASS']
			page = agent.submit(login_form)
			# login second screen
			login_form = page.form('form01')
			login_form.UID = ENV['INFOMART_LOGIN']
			login_form.PWD = ENV['INFOMART_PASS']
			page = agent.submit(login_form)
			puts "Login successful, downloading the latest CSV order data."
			csv_id = page.links_with(dom_class: 'ic ic-blu-dl').first.href[/D\d*\.asp/]
			csv_call_url = "https://ec.infomart.co.jp/trade/download/download_inside_caller.aspx?file_id= &call_file=#{csv_id}"
			csv = agent.get(csv_call_url)
			filename = csv.filename
			puts "Saving #{filename} for processing"
			csv.save
			existing_updated = Set.new
			newly_created = Set.new
			puts "Processing data..."
			process_csv(filename, existing_updated, newly_created)
			puts "#{newly_created.length + existing_updated.length} Infomart order changes were made, #{newly_created.length} newly created and #{existing_updated.length} existing orders found and, if necessary, updated."
			File.delete(filename) if File.exist?(filename)
			puts "Scheduled task appears to have triggered an error, 
				the latest CSV is not bearing today's date (#{self.date.strftime('%Y/%m/%d')} != #{@csv_date}). 
				Check Infomart's scheduled task area for more information." if (@csv_date != self.date.strftime('%Y/%m/%d'))
		else 
			puts 'Alternate acquisation methods are not yet supported, please use Mechanize'
		end
	end

end
