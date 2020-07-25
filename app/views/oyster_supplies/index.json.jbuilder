json.array!(@oyster_supply) do |supply|
	json.extract! supply, :id, :supply_date
	if @place == "supply_index"
		json.title '大　' + supply.large_shucked_total.to_s + '
		小　' + supply.small_shucked_total.to_s + '
		殻付き　' + supply.shells_total.to_s
	elsif @place == "supply_show"
		json.title ''
	else
	end
	json.start DateTime.strptime(supply.supply_date, '%Y年%m月%d日')
	json.allDay true
	json.className 'supply_event'
	json.backgroundColor ((supply.check_completion.empty?) ? 'rgba(185, 232, 247, 0.24)' : '#DC7632')
	json.textColor 'black'
	json.borderColor 'rgba(255, 255, 255, 0)'
	json.url oyster_supply_url(supply)
end

json.array!(@oyster_invoices) do |invoice|
	if @place == "supply_index"
		start_date = DateTime.strptime(invoice.start_date, '%Y-%m-%d')
		end_date = DateTime.strptime(invoice.end_date, '%Y-%m-%d')
		json.extract! invoice, :id, :start_date, :end_date
		json.title to_nengapi(start_date) + 'から' + to_nengapi(end_date) + 'の仕切り'
		json.className 'invoice_event'
		json.start start_date
		json.end end_date
		json.allDay true
		json.backgroundColor 'rgba(0, 84, 0, 1)'
		json.textColor 'white'
		json.borderColor 'rgba(255, 255, 255, 0)'
		json.url '#'
	end
end
