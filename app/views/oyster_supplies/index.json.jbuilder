json.array!(@oyster_supply) do |supply|
	if @place == "supply_index"
		json.title "兵庫 #{supply.totals[:sakoshi_total].round(0).to_s}#{current_user.admin? ? "  @#{supply.totals[:sakoshi_avg_kilo].round(0).to_s}" : ""}
		岡山 #{supply.totals[:okayama_total].round(0).to_s}#{current_user.admin? ? " @#{supply.totals[:okayama_avg_kilo].round(0).to_s}" : ""}
		殻付 #{supply.totals[:shell_total].round(0).to_s}" + (current_user.admin? ? " @#{supply.totals[:big_shell_avg_cost].round(0).to_s}
			合計 #{supply.totals[:mukimi_total].round(0).to_s} @#{supply.totals[:total_kilo_avg].round(0).to_s}" : "")
	elsif @place == "supply_show"
		json.title ""
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
if @place == "supply_index"
	json.array!(@oyster_invoices) do |invoice|
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
		json.url oyster_invoice_url(invoice)
	end
end
