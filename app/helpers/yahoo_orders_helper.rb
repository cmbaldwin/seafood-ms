module YahooOrdersHelper

	def status_color(order)
		s = order.order_status(false)
		if s == 1 || s ==  2 || s ==  3
			"info"
		elsif s == 5
			"success"
		else
			"danger"
		end
	end

	def print_shipping_name(order)
		if order.billing_name != order.shipping_name
			order.shipping_name
		else
			'""'
		end
	end

end
