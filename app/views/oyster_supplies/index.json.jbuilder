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
	json.backgroundColor 'rgba(185, 232, 247, 0.24)'
	json.textColor 'black'
	json.borderColor 'rgba(255, 255, 255, 0)'
	json.url oyster_supply_url(supply)
end