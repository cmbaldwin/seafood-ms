json.array!(@oyster_supply) do |supply|
	if @place == "supply_index"
		json.title "#{supply.totals[:mukimi_total].round(0).to_s}㎏　#{ "@#{supply.totals[:total_kilo_avg].round(0).to_s}¥/㎏" if (current_user.admin? && supply.check_completion.empty?)}"
	elsif @place == "supply_show"
		json.title ""
	else
	end
	json.start DateTime.strptime(supply.supply_date, '%Y年%m月%d日')
	json.allDay true
	json.className "supply_event tippy_#{supply.id}"
	json.supply_id supply.id
	json.description current_user.admin? ? "
		<div class='container-flex small'>
			<table class='table table-sm table-hover table-striped table-dark'>
				<thead>
					<tr>
						<th scope='col'>場所</th>
						<th scope='col'>
							量
						</th>
						<th scope='col'>単価(¥/㎏)</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<th scope='row'>兵庫</th>
						<td>
							#{supply.totals[:sakoshi_total].round(0).to_s}㎏<br>
							( 大#{supply.large_shucked_total.round(0)}㎏ / 小#{supply.small_shucked_total.round(0)}㎏)
						</td>
						<td>@#{supply.totals[:sakoshi_avg_kilo].round(0).to_s}㎏</td>
					</tr>
					<tr>
						<th scope='row'>岡山</th>
						<td>#{supply.totals[:okayama_total].round(0).to_s}㎏</td>
						<td>@#{supply.totals[:okayama_avg_kilo].round(0).to_s}</td>
					</tr>
					<tr>
						<th scope='row'>殻付</th>
						<td>#{supply.totals[:shell_total].round(0).to_s}個 / #{supply.thin_shells_total}㎏</td>
						<td>@#{supply.totals[:big_shell_avg_cost].round(0).to_s}</td>
					</tr>
					<tr>
						<th scope='row'>合計</th>
						<td>#{supply.totals[:mukimi_total].round(0).to_s}㎏</td>
						<td>@#{supply.totals[:total_kilo_avg].round(0).to_s}㎏</td>
					</tr>
				</tbody>
			</table>
		</div>" : ""
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
