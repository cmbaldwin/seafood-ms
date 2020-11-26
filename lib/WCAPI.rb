class WCAPI
	require "json"

	def initialize(endpoint = 'orders', count = '100', search = '')
		@endpoint = endpoint
		@response = JSON.load(open('https://www.funabiki.info/wp-json/wc/v3/' + @endpoint + '?per_page=' + count + '&search=' + search + '&consumer_key=' + ENV['WOOCOMMERCE_CONSUMER_KEY'] + '&consumer_secret=' + ENV['WOOCOMMERCE_CONSUMER_SECRET']))
	end

	def print(count = 100)
		# for debugging in console
		ap @response[0..count]
	end

	def response
		# return json response
		@response
	end

	def shinki
		# returns orders without a tracking code, meaning they have not be processed
		if @endpoint == 'orders'
			shinki = Array.new
			@response.each do |order|
				tracking_number = order["meta_data"].map { |h| h["value"] if (h["key"] == "ywot_tracking_code") }.compact.first
				if (tracking_number == "") || (tracking_number.nil?)
					shinki << order unless order["status"] == "cancelled"
				end
			end
			shinki
		else
			puts 'Wrong endpoint for this action'
		end
	end

end
