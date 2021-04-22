class WCAPI
	require "json"

	def initialize(endpoint = 'orders', count = '100', search = '')
		@endpoint = endpoint
		@count = count
		@search = search
		# https://woocommerce.github.io/woocommerce-rest-api-docs/?ruby
		p "Connection opening with Funabiki.info Woocommerce API v3 at endpoint #{@endpoint}..."
		@response = JSON.load(open('https://www.funabiki.info/wp-json/wc/v3/' + @endpoint + "#{'?per_page=' + count if count.to_i > 0}" + "#{'&search=' + search unless search.empty?}" + '&consumer_key=' + ENV['WOOCOMMERCE_CONSUMER_KEY'] + '&consumer_secret=' + ENV['WOOCOMMERCE_CONSUMER_SECRET']))
		p "Response loaded"
	end

	def print(count = 100)
		# for debugging in console
		p "Debug mode...printing #{@count} response hashes from the #{@endpoint} endpoint"
		ap @response[0..count]
		@response[0..count]
	end

	def response
		# return default json response
		# Array of 100 most recent hashed orders
		# https://woocommerce.github.io/woocommerce-rest-api-docs/?ruby#orders
		p "Returning response for further processing..."
		@response
	end

	def get_metadata(order_data, key_str)
		order_data["meta_data"].map{|a| a["value"] if a["key"] == key_str }.compact.first
	end

	def update
		# returns orders without a tracking code, meaning they have not be processed
		if @endpoint == 'orders'
			p "Iterating through most recent #{@count} orders"
			@response.each do |order_data|
				begin
					order = OnlineOrder.find_by(order_id: order_data["id"])
					order = OnlineOrder.new(order_id: order_data["id"]) if order.nil?
					ship_date = self.get_metadata(order_data, "ywot_pick_up_date")
					(ship_date = nil if ship_date.empty?) unless ship_date.nil?
					parsed_ship_date = Date.strptime(ship_date, "%Y-%m-%d") unless ship_date.nil?
					arrival_date = self.get_metadata(order_data, "wc4jp-delivery-date")
					unless (arrival_date.nil? || arrival_date.empty?)
						if arrival_date.include?('-') && (arrival_date.length == 10)
							arrival_date_parsed = Date.strptime(arrival_date, "%Y-%m-%d")
						else
							arrival_date_parsed = Date.strptime(arrival_date, "%Y年%m月%d日")
						end
					end
					order.assign_attributes({ 
						order_time: DateTime.parse(order_data["date_created"]), 
						date_modified: DateTime.parse(order_data["date_modified"]),
						status: order_data["status"],
						ship_date: parsed_ship_date ? parsed_ship_date : nil,
						arrival_date: arrival_date_parsed ? arrival_date_parsed : nil,
						data: order_data
					})
					order.save
				rescue => e
					p e.message
					e.backtrace.each { |line| p line }
				end; nil
			end; nil
		else
			puts 'Wrong endpoint for this action'
		end
	end

	def shinki
		# returns orders without a tracking code, meaning they have not be processed
		if @endpoint == 'orders'
			shinki = Array.new
			@response.each do |order|
				tracking_number = order["meta_data"].map { |h| h["value"] if (h["key"] == "ywot_tracking_code") }.compact.first
				if (tracking_number == "") || (tracking_number.nil?)
					shinki << order unless (order["status"] == "cancelled") || (order["status"] == "completed") || (order["status"] == "refunded")
				end
			end
			shinki
		else
			puts 'Wrong endpoint for this action'
		end
	end

end
