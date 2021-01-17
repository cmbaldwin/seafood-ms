json.array!(@calendar_profits) do |profit|
	json.title (profit.totals[:profits].nil? || profit.totals.empty?) ? ('未計算') : ('￥' + yenify(profit.totals[:profits]) + (profit.alone? ? ('') : (profit.check_ampm ? '　午前' : '　午後')))
	json.start DateTime.strptime(profit.sales_date, '%Y年%m月%d日')
	json.id profit.id
	json.allDay true
	json.className 'profit_event'
	unless profit.alone?
		if profit.check_ampm
			json.backgroundColor 'rgba(185, 232, 247, 0.24)'
			json.textColor 'black'
		end
	end
	json.borderColor 'rgba(255, 255, 255, 0)'
	json.url profit_url(profit)
end
