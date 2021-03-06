order_counts = Hash.new

@yahoo_orders.each do |order|
	order_counts[order.ship_date].nil? ? order_counts[order.ship_date] = 1 : order_counts[order.ship_date] += 1
end

@new_orders.each do |order|
	unless order.order_status(false) == 4
		order_counts[Date.today].nil? ? order_counts[Date.today] = 1 : order_counts[Date.today] += 1
	end
end

json.array!(order_counts) do |ship_date, count|
	json.title count.to_s
	json.start ship_date
	json.end ship_date
	json.allDay true
	json.className (ship_date == Date.today ? 'new_order_count' : 'order_count')
	json.backgroundColor (ship_date == Date.today ? '#DC7632' : 'rgba(185, 232, 247, 0.24)')
	json.textColor 'black'
	json.borderColor 'rgba(255, 255, 255, 0)'
end