module ApplicationHelper

	def title(page_title)
		content_for(:title) { page_title }
	end

	def weekday_japanese(num)
		#d.strftime("%w") to Japanese
		weekdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
		weekdays[num]
	end

	def yenify(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "")
	end

	def yenify_with_decimal(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "", precision: 1)
	end
	
	def cycle_table_rows
		cycle("even", "odd")
	end

	def nengapi_today
		Date.today.strftime('%Y年%m月%d日')
	end

	def nengapi_today_plus(number)
		(Date.today + number).strftime('%Y年%m月%d日')
	end

	def icon(icon, options = {})
		file = File.read("#{Rails.root}/node_modules/bootstrap-icons/icons/#{icon}.svg")
		doc = Nokogiri::HTML::DocumentFragment.parse file
		svg = doc.at_css 'svg'
		if options[:class].present?
			svg['class'] += " " + options[:class]
		end
		doc.to_html.html_safe
	end

	def get_infomart_backend_link(backend_id)
		'https://www2.infomart.co.jp/trade/trade_detail.page?14&tid=' + backend_id + '&del_hf=1&through_status_code&returned_flg'
	end

	def yahoo_order_counts(orders)
		counts = Hash.new
		types_arr = %w{生むき身 生セル(カード) セルカード 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(80g) 干し殻付エビ(80g) タコ}
		types_arr.each {|w| counts[w] = 0}
		count_hash = { 
			"kakiset302" => [2, 30, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset202" => [2, 20, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset301" => [1, 30, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset201" => [1, 20, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset101" => [1, 10, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki100" => [0, 100, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki50" => [0, 50, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki40" => [0, 40, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki30" => [0, 30, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki20" => [0, 20, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki10" => [0, 10, 1, 0, 0, 0, 0, 0, 0, 0],
			"mukimi04" => [4, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"mukimi03" => [3, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"mukimi02" => [2, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"mukimi01" => [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"pkara100" => [0, 0, 0, 0, 100, 0, 0, 0, 0, 0],
			"pkara50" => [0, 0, 0, 0, 50, 0, 0, 0, 0, 0],
			"pkara40" => [0, 0, 0, 0, 40, 0, 0, 0, 0],
			"pkara30" => [0, 0, 0, 0, 30, 0, 0, 0, 0, 0],
			"pkara20" => [0, 0, 0, 0, 20, 0, 0, 0, 0, 0],
			"pkara10" => [0, 0, 0, 0, 10, 0, 0, 0, 0, 0],
			"pmuki04" => [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
			"pmuki03" => [0, 0, 0, 3, 0, 0, 0, 0, 0, 0],
			"pmuki02" => [0, 0, 0, 2, 0, 0, 0, 0, 0, 0],
			"pmuki01" => [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
			"tako1k" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			"mebi80x5" => [0, 0, 0, 0, 0, 0, 0, 5, 0, 0],
			"mebi80x3" => [0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
			"hebi80x10" => [0, 0, 0, 0, 0, 0, 0, 0, 10, 0],
			"hebi80x5" => [0, 0, 0, 0, 0, 0, 0, 0, 5, 0],
			"anago600" => [0, 0, 0, 0, 0, 1, 600, 0, 0, 0],
			"anago480" => [0, 0, 0, 0, 0, 1, 480, 0, 0, 0],
			"anago350" => [0, 0, 0, 0, 0, 1, 350, 0, 0, 0] }
		orders.each do |order|
			unless order.order_status(false) == 4
				count_hash[order.item_id].each_with_index do |count, i|
					counts[types_arr[i]] += count
				end
			end
		end
		cards = counts.values[2]
		anago = counts.values[6]
		results = {headers: counts.keys, values: counts.values, anago: anago, cards: cards}
		["セルカード", "穴子(g)"].each do |t|
			i = results[:headers].index(t)
			[:headers, :values].each {|k| results[k].delete_at(i)}
		end
		results
	end

end
