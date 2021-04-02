json.array!(@infomart_orders) do |order|
	start_date = order.ship_date
	end_date = order.ship_date
	json.className 'order'
	json.start start_date
	json.end end_date
	json.allDay true
	json.url infomart_order_path(order.id)
end