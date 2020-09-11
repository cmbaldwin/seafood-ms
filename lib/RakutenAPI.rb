class RakutenAPI
	include HTTParty
	require 'json'
	# There is one required variable
	# Base64.encode64(x + ":"  + y) then remove the \n (there should be two)
	# authorization = 'ESA ' + ENV['RAKUTEN_API']

	def initialize
		# We use the first user as a default because our first user is an admin
		authorization = 'ESA ' + ENV['RAKUTEN_API']
		@auth_header = { 
			"Authorization" => authorization,
			"Content-Type" => "application/json; charset=utf-8"
		}
	end

	def get_ids_by_sales_date(sales_date = Date.today.strftime("%Y年%m月%d日"))
		sales_date = sales_date
		start_date_time = DateTime.strptime(sales_date, "%Y年%m月%d日").strftime('%Y-%m-%dT%H:%M:%S') + '+0900'
		end_date_time = (DateTime.strptime(sales_date, "%Y年%m月%d日") + 23.hours + 59.minutes + 59.seconds).strftime('%Y-%m-%dT%H:%M:%S') + '+0900'


		get_orders_list = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/searchOrder/",
			:headers => @auth_header,
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
		get_orders_list.parsed_response
	end

	#get one week of new orders
	def get_shinki_ids(finish_date = Date.today, period_back = 7.days)
		date = Date.today
		start_date_time = (date - period).strftime('%Y-%m-%dT%H:%M:%S') + '+0900'
		end_date_time = (date + 23.hours + 59.minutes + 59.seconds).strftime('%Y-%m-%dT%H:%M:%S') + '+0900'


		get_orders_list = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/searchOrder/",
			:headers => @auth_header,
			:body => { 
				"dateType" => 1, 
				"startDatetime" => start_date_time,
				"endDatetime" => end_date_time,
				"PaginationRequestModel" => {
					"requestRecordsAmount" => 1000,
					"requestPage" => 1,
					"SortModelList" => [{
						"sortColumn" => 1,
						"sortDirection" => 1 }]
			}}.to_json)
		get_orders_list.parsed_response["orderNumberList"]
	end

	#get one week of new orders
	def get_shinki_without_shipdate_ids(finish_date = Date.today, period_back = 7.days)
		start_date_time = (finish_date - period_back).strftime('%Y-%m-%dT%H:%M:%S') + '+0900'
		end_date_time = (finish_date + 23.hours + 59.minutes + 59.seconds).strftime('%Y-%m-%dT%H:%M:%S') + '+0900'


		get_orders_list = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/searchOrder/",
			:headers => @auth_header,
			:body => { 
				# only incomplete orders unless + 500,600,700,800,900
				"orderProgressList" => [100,200,300,400],
				"dateType" => 1, 
				"startDatetime" => start_date_time,
				"endDatetime" => end_date_time,
				"shippingDateBlankFlag" => 1,
				"PaginationRequestModel" => {
					"requestRecordsAmount" => 1000,
					"requestPage" => 1,
					"SortModelList" => [{
						"sortColumn" => 1,
						"sortDirection" => 1 }]
			}}.to_json)
		get_orders_list["orderNumberList"]
	end

	def get_details_by_ids(id_array)
		if id_array.length > 100
			orders_list_by_100 = id_array.each_slice(100).to_a
			order_details = Array.new
			messages = Array.new
			orders_list_by_100.each do |sub_list|
				get_order_details = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/getOrder/",
					:headers => @auth_header,
					:body => {"orderNumberList" => sub_list}.to_json)
				order_details << get_order_details["OrderModelList"]
				messages << get_order_details["MessageModelList"]
			end
		else
			get_order_details = HTTParty.post("https://api.rms.rakuten.co.jp/es/2.0/order/getOrder/",
				:headers => @auth_header,
				:body => {"orderNumberList" => id_array}.to_json)
			order_details = get_order_details["OrderModelList"]
			messages = get_order_details["MessageModelList"]
		end
		order_details
	end

end