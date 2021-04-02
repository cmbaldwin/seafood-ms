class PrawnPDF
	require 'prawn-rails'

	# Note: rendering data in browser with "send_data" uses server ram until the document is closed--
	# Prefer generation via sidekiq/async -> stream to cloud service -> message user with completed file.

	def self.fonts
		{
			"MPLUS1p" => {
				:normal => Rails.root.join(".fonts/MPLUS1p-Regular.ttf"),
				:bold => Rails.root.join(".fonts/MPLUS1p-Bold.ttf"),
				:light => Rails.root.join(".fonts/MPLUS1p-Light.ttf"),
			},
			"Sawarabi" => {
				:normal => Rails.root.join(".fonts/SawarabiMincho-Regular.ttf"),
			},
			"TakaoPMincho" => {
				:normal => Rails.root.join(".fonts/TakaoPMincho.ttf"),
			}
		}
	end

	def self.online_orders_table_array(data_table, online_orders, type)
		def self.frozen?(product_id)
			result = false
			{ [437, 516, 517, 519, 520, 521, 838, 522, 837, 523, 13867, 13883, 13884, 13885, 583, 581, 580, 579, 578, 577,  6555, 6556, 6557, 6558, 6559, 6560, 584, 590, 591, 592, 593, 594, 596, 595, 598, 599, 600, 597, 572, 575, 576, 500, 6319] => false,
				[524, 645, 646, 6554, 13551, 13552, 13585, 13584, 13583, 13582, 13580, 13579, 13577, 13586, 13587, 13588] => true }.each do |id_array, bool|
					result = bool if id_array.include?(product_id) 
			end
			result
		end
		if ((type == :raw) || (type == :all))
			def self.is_a_set?(item_count)
				(item_count[0] > 0) && (item_count[1] > 0)
			end
			def self.is_other?(item_count, type)
				type == :raw ? (!item_count[6..10].sum.zero?) : (!item_count[4..10].sum.zero?)
			end
			i = 0
			online_orders.each do |order|
				# Raw format unified for Rakuten, Yahoo and Funabiki.info
				# ['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']
				ii = 0
				order.items.each do |item|
					product_id = item["product_id"]
					unless ((type == :raw) && (self.frozen?(product_id)))
						item_count = order.item_count(product_id)
						order_row = Array.new
						order_row << (ii == 0 ? (i + 1).to_s : '')
						order_row << (ii == 0 ? order.sender_name : '""')
						order_row << (ii == 0 ? (order.unique_recipient ? order.recipient_name : '""') : '""')
						order_row << (self.is_a_set?(item_count) ? '' : (item_count[0] > 0 ? "500gx#{item_count[0]}" : ''))
						order_row << (self.is_a_set?(item_count) ? '' : (item_count[1] > 0 ? "#{item_count[1]}個" : '') + (item_count[2] > 0 ? "#{'・' if (item_count[1] > 0)}#{item_count[2]}kg" : ''))
						order_row << (self.is_a_set?(item_count) ? "#{item_count[0]}パック + #{item_count[1]}個" : '')
						order_row << (self.is_other?(item_count, type) ? order.item_name(product_id) : '')
						order_row << (ii == 0 ? (order.arrival_date ? order.arrival_date.to_s : '') : '')
						order_row << (ii == 0 ? (order.arrival_time ? order.arrival_time : '') : '')
						order_row << (product_id == 500 ? order.knife : '')
						order_row << (product_id == 6319 ? order.noshi : '')
						order_row << ''
						order_row << ''
						data_table << order_row
						ii += 1
					end
				end
				i += 1
			end
		elsif type == :frozen
			i = 0
			online_orders.each do |order|
				# Frozen format for combining with infomart
				# ['#', '飲食店', '500g (L)', '500g (LL)', '500g (生)', 'セル (100)', '小セル', 'お届け日', '時間', '備考']
				ii = 0
				order.items.each do |item|
					product_id = item["product_id"]
					unless self.frozen?(product_id)
						item_count = order.item_count(product_id)
						quantity = item["quantity"]
						order_row = Array.new
						order_row << (ii == 0 ? (i + 1).to_s : '')
						order_row << (ii == 0 ? order.sender_name : '""')
						order_row << (ii == 0 ? (order.unique_recipient ? order.recipient_name : '""') : '')
						order_row << (self.is_a_set?(item_count) ? '' : (item_count[0] > 0 ? "#{item_count[0]}#{(' x' + quantity) if quantity > 1 }" : ''))
						order_row << (self.is_a_set?(item_count) ? '' : (item_count[1] > 0 ? "#{item_count[1]}個#{(' x' + quantity) if quantity > 1 }" : '') + (item_count[2] > 0 ? "#{'・' if (item_count[1] > 0)}#{item_count[2]}kg" : ''))
						order_row << (self.is_a_set?(item_count) ? "500gx#{item_count[0]} + #{item_count[1]}個#{(' x' + quantity) if quantity > 1 }" : '')
						order_row << (self.is_other?(item_count) ? "#{order.item_name(product_id)}#{(' x' + quantity) if quantity > 1 }" : '')
						order_row << (ii == 0 ? (order.arrival_date ? order.arrival_date.to_s : '') : '')
						order_row << (ii == 0 ? (order.arrival_time ? order.arrival_time : '') : '')
						order_row << (product_id == 500 ? "#{order.knife}#{(' x' + quantity) if quantity > 1 }" : '')
						order_row << (product_id == 6319 ? "#{order.noshi}#{(' x' + quantity) if quantity > 1 }" : '')
						order_row << ''
						order_row << ''
						data_table << order_row
						ii += 1
					end
				end
				i += 1
			end
		end
	end

	def self.online_orders(ship_date, filename)
		online_orders = OnlineOrder.where(ship_date: ship_date)

		Prawn::Document.generate(filename, margin: [15]) do |pdf|
			pdf.font_families.update(fonts)
			#set utf-8 japanese font
			pdf.font_size 16
			pdf.font "MPLUS1p", style: :bold
			pdf.text "#{ship_date} Funabiki.info 発送表"
			pdf.font "MPLUS1p", style: :normal
			pdf.move_down 15
			# raw
			data_table = [['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']]
			self.online_orders_table_array(data_table, online_orders, :all)
			5.times do
				data_table << ['　'] * 13
			end
			pdf.table( data_table,
				:header => true,
				:cell_style => {
					:border_width => 0.25,
					:size => 10,
					:valign => :center},
				:column_widths => {},
				:width => pdf.bounds.width ) do

				cells.columns(1..2).rows(1..-1).font = "TakaoPMincho"

				cells.column(0).rows(1..-1).padding = 2
				cells.columns(1..-1).rows(1..-1).padding = 4

				header_cells = cells.columns(0..12).rows(0)
				header_cells.background_color = "acacac"
				header_cells.size = 7
				header_cells.font_style = :bold

				cells.columns(7).rows(1..-1).font_style = :light

				set_other_time_cells = cells.columns([5, 6, 7, 8, 12]).rows(1..-1)
				set_other_time_cells.size = 7

				item_cells = cells.columns(3..6).rows(1..-1)
				multi_cells = item_cells.filter do |cell|
					cell.content.to_s[/!/]
				end
				multi_cells.background_color ="ffc48f"

				item_cells = cells.columns(9..11).rows(1..-6)
				check_cells = item_cells.filter do |cell|
					!cell.content.to_s.empty?
				end
				check_cells.background_color ="ffc48f"


				note_cells = cells.columns(12).rows(1..-1)
				cash_cells = note_cells.filter do |cell|
					cell.content.to_s[/代引/]
				end
				cash_cells.background_color ="ffc48f"

				date_cells = cells.columns(7).rows(1..-1)
				not_tomorrow_cells = date_cells.filter do |cell|
					cell.content.to_s[/月/]
				end
				not_tomorrow_cells.background_color ="ffc48f"
			end

			return pdf
		end
	end

	def self.yahoo(ship_date, filename)
		orders = YahooOrder.where(ship_date: ship_date)

		def self.order_counts(orders)
			counts = Hash.new
			types_arr = %w{生むき身 生セル 小殻付 セルカード 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(80g) 干し殻付エビ(80g) タコ}
			types_arr.each {|w| counts[w] = 0}
			count_hash = {
				"kakiset302" => [2, 30, 0, 1, 0, 0, 0, 0, 0],
				"kakiset202" => [2, 20, 0, 1, 0, 0, 0, 0, 0],
				"kakiset301" => [1, 30, 0, 1, 0, 0, 0, 0, 0],
				"kakiset201" => [1, 20, 0, 1, 0, 0, 0, 0, 0],
				"kakiset101" => [1, 10, 0, 1, 0, 0, 0, 0, 0],
				"karatsuki100" => [0, 100, 0, 1, 0, 0, 0, 0, 0],
				"karatsuki50" => [0, 50, 0, 1, 0, 0, 0, 0, 0],
				"karatsuki40" => [0, 40, 0, 1, 0, 0, 0, 0, 0],
				"karatsuki30" => [0, 30, 0, 1, 0, 0, 0, 0, 0],
				"karatsuki20" => [0, 20, 0, 1, 0, 0, 0, 0, 0],
				"karatsuki10" => [0, 10, 0, 1, 0, 0, 0, 0, 0],
				"mukimi04" => [4, 0, 0, 0, 0, 0, 0, 0, 0],
				"mukimi03" => [3, 0, 0, 0, 0, 0, 0, 0, 0],
				"mukimi02" => [2, 0, 0, 0, 0, 0, 0, 0, 0],
				"mukimi01" => [1, 0, 0, 0, 0, 0, 0, 0, 0],
				"pkara100" => [0, 0, 0, 100, 0, 0, 0, 0, 0],
				"pkara50" => [0, 0, 0, 50, 0, 0, 0, 0, 0],
				"pkara40" => [0, 0, 0, 40, 0, 0, 0, 0],
				"pkara30" => [0, 0, 0, 30, 0, 0, 0, 0, 0],
				"pkara20" => [0, 0, 0, 20, 0, 0, 0, 0, 0],
				"pkara10" => [0, 0, 0, 10, 0, 0, 0, 0, 0],
				"pmuki04" => [0, 0, 1, 0, 0, 0, 0, 0, 0],
				"pmuki03" => [0, 0, 3, 0, 0, 0, 0, 0, 0],
				"pmuki02" => [0, 0, 2, 0, 0, 0, 0, 0, 0],
				"pmuki01" => [0, 0, 1, 0, 0, 0, 0, 0, 0],
				"tako1k" => [0, 0, 0, 0, 0, 0, 0, 0, 1],
				"mebi80x5" => [0, 0, 0, 0, 0, 0, 5, 0, 0],
				"mebi80x3" => [0, 0, 0, 0, 0, 0, 3, 0, 0],
				"hebi80x10" => [0, 0, 0, 0, 0, 0, 0, 10, 0],
				"hebi80x5" => [0, 0, 0, 0, 0, 0, 0, 5, 0],
				"anago600" => [0, 0, 0, 0, 1, 600, 0, 0, 0],
				"anago480" => [0, 0, 0, 0, 1, 480, 0, 0, 0],
				"anago350" => [0, 0, 0, 0, 1, 350, 0, 0, 0],
				"syoukara1kg" => [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
				"syoukara2kg" => [0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0],
				"syoukara3kg" => [0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0],
				"syoukara5kg" => [0, 0, 5, 1, 0, 0, 0, 0, 0, 0, 0]}
				orders.each do |order|
				unless order.order_status(false) == 4
					count_hash[order.item_id].each_with_index do |count, i|
						counts[types_arr[i]] += count
					end
				end
			end
			[counts.keys, counts.values]
		end

		def self.print_items(order)
			print_array = {
				"kakiset302" => ["", "", "500g×2 + 30個", ""],
				"kakiset202" => ["", "", "500g×2 + 20個", ""],
				"kakiset301" => ["", "", "500g×1 + 30個", ""],
				"kakiset201" => ["", "", "500g×1 + 20個", ""],
				"kakiset101" => ["", "", "500g×1 + 10個", ""],
				"karatsuki100" => ["", "100個", "", ""],
				"karatsuki50" => ["", "50個", "", ""],
				"karatsuki40" => ["", "40個", "", ""],
				"karatsuki30" => ["", "30個", "", ""],
				"karatsuki20" => ["", "20個", "", ""],
				"karatsuki10" => ["", "10個", "", ""],
				"syoukara1kg" => ["", "小1㎏", "", ""],
				"syoukara2kg" => ["", "小2㎏", "", ""],
				"syoukara3kg" => ["", "小3㎏", "", ""],
				"syoukara5kg" => ["", "小5㎏", "", ""],
				"mukimi04" => ["4", "", "", ""],
				"mukimi03" => ["3", "", "", ""],
				"mukimi02" => ["2", "", "", ""],
				"mukimi01" => ["1", "", "", ""],
				"pkara100" => ["", "", "", "冷凍セル 100個"],
				"pkara50" => ["", "", "", "冷凍セル 50個"],
				"pkara40" => ["", "", "", "冷凍セル 40個"],
				"pkara30" => ["", "", "", "冷凍セル 30個"],
				"pkara20" => ["", "", "", "冷凍セル 20個"],
				"pkara10" => ["", "", "", "冷凍セル 10個"],
				"pmuki04" => ["", "", "", "冷凍500g×4"],
				"pmuki03" => ["", "", "", "冷凍500g×3"],
				"pmuki02" => ["", "", "", "冷凍500g×2"],
				"pmuki01" => ["", "", "", "冷凍500g×1"],
				"tako1k" => ["", "", "", "ボイルたこ"],
				"mebi80x5" => ["", "", "", "干しむきエビ 80gx5"],
				"mebi80x3" => ["", "", "", "干しむきエビ 80gx3"],
				"hebi80x10" => ["", "", "", "干し殻付エビ 80gx10"],
				"hebi80x5" => ["", "", "", "干し殻付エビ 80gx5"],
				"anago600" => ["", "", "", "焼き穴子600g"],
				"anago480" => ["", "", "", "焼き穴子480g"],
				"anago350" => ["", "", "", "焼き穴子350g"] }
			print_array[order.item_id] 
		end

		Prawn::Document.generate(filename, margin: [15]) do |pdf|
			pdf.font_families.update(fonts)
			#set utf-8 japanese font
			pdf.font_size 16
			pdf.font "MPLUS1p", style: :bold
			pdf.text "#{ship_date} ヤフーショッピング 発送表"
			pdf.font "MPLUS1p", style: :normal
			pdf.move_down 15
			pdf.table(order_counts(orders),
					:cell_style => {
						:inline_format => true,
						:border_width => 0.25,
						:valign => :center,
						:align => :center,
						:size => 10},
					:width => pdf.bounds.width ) do |t|
				t.row(0).background_color = "acacac"
			end
			pdf.move_down 15
			data_table = [['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']]
			orders.each_with_index do |order, i|
				item = print_items(order)
				order_arr = [(i + 1).to_s]
				order_arr << order.billing_name
				order_arr << (order.billing_name == order.shipping_name ? '""' : order.shipping_name)
				item.each do |item|
					order_arr << (item.empty? ? item : (item + order.print_quantity))
				end
				order_arr << order.shipping_arrival_date.strftime("%Y/%m/%d")
				order_arr << order.arrival_time
				order_arr << ""
				order_arr << ""
				order_arr << ""
				order_arr << ""

				data_table << order_arr
			end
			5.times do
				data_table << ['　'] * 13
			end
			pdf.font_size 8
			pdf.table(data_table,
				:header => true,
				:cell_style => {
					:border_width => 0.25,
					:valign => :center},
				:column_widths => {0 => 18, 1 => 55, 2 => 55, 3 => 30, 4 => 27, 5=> 50, 12=> 100},
				:width => pdf.bounds.width ) do

				cells.columns(1..2).rows(1..-1).font = "TakaoPMincho"

				cells.column(0).rows(1..-1).padding = 2
				cells.columns(1..-1).rows(1..-1).padding = 4

				header_cells = cells.columns(0..12).rows(0)
				header_cells.background_color = "acacac"
				header_cells.size = 7
				header_cells.font_style = :bold

				cells.columns(7).rows(1..-1).font_style = :light

				set_other_time_cells = cells.columns([5, 6, 7, 8, 12]).rows(1..-1)
				set_other_time_cells.size = 7

				item_cells = cells.columns(3..6).rows(1..-1)
				multi_cells = item_cells.filter do |cell|
					cell.content.to_s[/!/]
				end
				multi_cells.background_color ="ffc48f"

				item_cells = cells.columns(9..11).rows(1..-6)
				check_cells = item_cells.filter do |cell|
					!cell.content.to_s.empty?
				end
				check_cells.background_color ="ffc48f"


				note_cells = cells.columns(12).rows(1..-1)
				cash_cells = note_cells.filter do |cell|
					cell.content.to_s[/代引/]
				end
				cash_cells.background_color ="ffc48f"

				date_cells = cells.columns(7).rows(1..-1)
				not_tomorrow_cells = date_cells.filter do |cell|
					cell.content.to_s[/月/]
				end
				not_tomorrow_cells.background_color ="ffc48f"
			end

			return pdf
		end
	end

	def self.add_row(data_table, rows)
		data_table << ['　'] * rows
	end

	def self.weekday_japanese(num)
		#d.strftime("%w") to Japanese
		weekdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
		weekdays[num]
	end

	def self.infomart(ship_date, filename, include_online)
		def self.unified_styles(t)
			t.cells.column(1).rows(1..-1).font = "TakaoPMincho"

			t.cells.column(0).rows(1..-1).size = 7

			t.cells.column(-2).rows(1..-1).size = 6

			center_columns = [ t.columns(2..-1) ]
			center_columns.each do |r|
				r.style( align: :center )
			end

			header_cells = t.cells.columns(0..-1).rows(0)
			header_cells.background_color = "acacac"
			header_cells.size = 9
			header_cells.font_style = :bold
		end
		def self.online_order_count(online_orders)
			online_orders = online_orders.reject{|o| o.cancelled }
			{
				raw: online_orders.map{|o| o.item_id_array.map{|i| o.is_raw?(i) ? 1 : 0 }.flatten }.sum.sum, 
				frozen: online_orders.map{|o| o.item_id_array.map{|i| o.is_frozen?(i) ? 1 : 0}.flatten }.sum.sum
			}
		end
		ship_date = Date.parse(ship_date)
		orders = InfomartOrder.where(ship_date: ship_date)
		online_orders = OnlineOrder.where(ship_date: ship_date)
		online_orders.empty? ? rf_counts = { :raw => 0 , :frozen => 0 } : rf_counts = online_order_count(online_orders)
		online_raw_count = online_orders.map{|o| (o.cancelled || o.print_item_array[:raw].empty?) ? 0 : o.print_item_array[:raw].length }.sum
		online_frozen_count = online_orders.map{|o| (o.cancelled || o.print_item_array[:frozen].empty?) ? 0 : o.print_item_array[:frozen].length }.sum

		Prawn::Document.generate(filename, margin: [15]) do |pdf|
			pdf.font_families.update(fonts)
			# Set utf-8 japanese font
			pdf.font_size 16
			pdf.font "MPLUS1p", style: :bold
			# Start the PDF for raw products
			pdf.text "#{ship_date} Infomart 発送表 (生食)"
			pdf.font "MPLUS1p", style: :normal
			pdf.move_down 15

			## Start raw order page
			data_table = [['#', '飲食店', '届け先', '500g', '1kg', 'セル', 'その他', 'お届け日', '時間', '備考']]
			i = 0
			orders.each do |order|
				unless order.counts.sum.zero?
					order.item_array[:raw].each do |item|
						data_table << item.unshift((i + 1).to_s)
						i += 1
					end
				end
			end
			0.times do
				data_table << (['　'] * 9).unshift((i + 1).to_s)
				i += 1
			end
			pdf.font_size 8
			pdf.table(data_table,
				:header => true,
				:cell_style => {
					:border_width => 0.25,
					:valign => :center},
				:column_widths => {0 => 20, 1 => 100, 2 => 51, 3 => 51, 4 => 51, 5 => 51, 7 => 51, 8 => 51, 9=> 100}, #bounds width is 582 (minus borders)
				:width => 582 ) do |t|

				# Style table here
				unified_styles(t)
			end
			# Extra lines
			# Raw orders for Funabiki.online => base height cost is 132 pt (1 orders) + each row/order is 19 pts
			online_raw_count.zero? ? (extra_lines = (pdf.cursor / 19)) : (extra_lines = (pdf.cursor - (online_raw_count * 19 + 132)) / 19)
			data_table = Array.new
			unless extra_lines.zero?
				(extra_lines.to_i - 2).times do
					data_table << (['　'] * 9).unshift((i + 1).to_s)
					i += 1
				end
				pdf.table(data_table,
					:header => true,
					:cell_style => {
						:border_width => 0.25,
						:valign => :center},
					:column_widths => {0 => 20, 1 => 100, 2 => 51, 3 => 51, 4 => 51, 5 => 51, 7 => 51, 8 => 51, 9=> 100}, #bounds width is 582 (minus borders)
					:width => pdf.bounds.width ) do |t|
				end
			end
			# Raw Online Orders
			if online_orders && (rf_counts[:raw] > 0)
				pdf.move_down 15
				pdf.font_size 16
				pdf.font "MPLUS1p", style: :bold
				# Start the PDF for raw products
				pdf.text "#{ship_date} Funabiki.info 発送表 (生食)"
				pdf.font "MPLUS1p", style: :normal
				pdf.move_down 15
				pdf.font_size 8
				data_table = [['#', '注文者', '届先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', '備考']]
				i = 0
				online_orders.each_with_index do |order, oi|
					unless order.cancelled || order.print_item_array[:raw].empty?
						order.print_item_array[:raw].each_with_index do |item_array, ii|
							data_table << (ii == 0 ? item_array.unshift("#{i + 1}") : item_array.unshift(""))
						end
						i += 1
					end
				end
				4.times do
					data_table << (['　'] * 9).unshift((i + 1).to_s)
					i += 1
				end
				pdf.table(data_table,
					:header => true,
					:cell_style => {
						:border_width => 0.25,
						:valign => :center},
					:column_widths => {},
					:width => pdf.bounds.width ) do |t|

					# Style table here
					unified_styles(t)
				end
			end

			## Start second page for frozen oysters
			pdf.start_new_page
			pdf.font_size 14
			pdf.font "MPLUS1p", :style => :bold
			pdf.text "#{ship_date} Infomart 発送表 (冷凍)"
			pdf.move_down 7
			pdf.font "MPLUS1p", :style => :normal
			data_table = [['#', '飲食店', '届け先', '500g (L)', '500g (LL)', '500g (生)', 'セル (100)', '小セル', 'お届け日', '時間', '備考']]
			i = 0
			orders.each do |order|
				unless order.counts.sum.zero?
					order.item_array[:frozen].each do |item|
						data_table << item.unshift((i + 1).to_s)
						i += 1
					end
				end
			end
			5.times do
				data_table << (['　'] * 10).unshift((i + 1).to_s)
				i += 1
			end
			pdf.font_size 8
			pdf.table(data_table,
				:header => true,
				:cell_style => {
					:border_width => 0.25,
					:valign => :center},
				:column_widths => {0 => 20, 1 => 80, 2 => 50, 3 => 50, 4 => 50, 5 => 50, 6 => 50, 7 => 50, 8 => 50, 10=> 80}, # of 582
				:width => pdf.bounds.width ) do |t|

				# Styling
				unified_styles(t)

			end
			# Extra lines
			# Frozen orders for Funabiki.online => base height cost is 132 pt (1 orders) + each row/order is 19 pts
			online_frozen_count.zero? ? (extra_lines = (pdf.cursor / 19)) : (extra_lines = (pdf.cursor - (online_frozen_count * 19 + 132)) / 19)
			data_table = Array.new
			unless extra_lines.zero?
				(extra_lines.to_i - 2).times do
					data_table << (['　'] * 10).unshift((i + 1).to_s)
					i += 1
				end
				pdf.table(data_table,
					:header => true,
					:cell_style => {
						:border_width => 0.25,
						:valign => :center},
					:column_widths => {0 => 20, 1 => 80, 2 => 50, 3 => 50, 4 => 50, 5 => 50, 6 => 50, 7 => 50, 8 => 50, 10=> 80}, # of 582
					:width => pdf.bounds.width ) do |t|
				end
			end
			# Frozen Online Orders
			if online_orders && (rf_counts[:frozen] > 0)
				i = 0
				pdf.move_down 15
				pdf.font_size 16
				pdf.font "MPLUS1p", style: :bold
				# Start the PDF for raw products
				pdf.text "#{ship_date} Funabiki.info 発送表 (冷凍)"
				pdf.font "MPLUS1p", style: :normal
				pdf.move_down 15
				pdf.font_size 8
				data_table = [['#', '注文者', '届先', '冷凍 500g', '冷凍 セル', 'お届け日', '時間', '備考']]
				online_orders.each_with_index do |order, oi|
					unless order.cancelled || order.print_item_array[:frozen].empty?
						order.print_item_array[:frozen].each_with_index do |item_array, ii|
							data_table << (ii == 0 ? item_array.unshift("#{i + 1}") : item_array.unshift(""))
						end
						i += 1
					end
				end
				4.times do
					data_table << (['　'] * 7).unshift((i + 1).to_s)
					i += 1
				end
				pdf.table(data_table,
					:header => true,
					:cell_style => {
						:border_width => 0.25,
						:valign => :center},
					:column_widths => {},
					:width => pdf.bounds.width ) do |t|

					# Style table here
					unified_styles(t)
				end
			end

			return pdf
		end
	end

	# OLD FORMAT
	def self.empty_manifest(filename, type)
		Prawn::Document.generate(filename, :page_size => "A4", :page_layout => :landscape, :margin => [25]) do |pdf_data|
			#document set up
			pdf_data.font_families.update(PrawnPDF.fonts)
			#set utf-8 japanese font
			pdf_data.font "MPLUS1p"
			#first page for raw oysters
				#print the date
				pdf_data.font_size 14
				pdf_data.font "MPLUS1p", :style => :bold
				pdf_data.text "#{type == '生食用' ? type : 'プロトン凍結冷凍用'} InfoMart/WooCommerce 発送表" + (type == '生食用' ? (( ' ' * (94))) : (' ' * (73))) + Date.today.strftime('%Y年%m月%d日')
				pdf_data.move_down 5
				pdf_data.font "MPLUS1p", :style => :normal

				#set up the data, make the header
				data_table = Array.new
				header_data_row = ['#', '注文者', 'お届け先', '500g', '1k', 'セル', '箱', 'お届け日', '時間', 'ナイフ', 'のし', '備考']
				data_table << header_data_row
				#add the rows
				25.times { add_row(data_table, 12) }
				pdf_data.font_size 8
				pdf_data.table( data_table, :cell_style => {:border_width => 0.25, :padding => 4 }, :column_widths => { 0 => 18, 1 => 100, 2 => 70, 3 => 50, 4 => 50, 5 => 100, 6 => 50, 7 => 50, 8 => 65, 9 => 50, 10 => 40 }, :width => 780 ) do
					rows(0..-1).each do |r|
						r.height = 20 if r.height < 20
					end

					center_columns = [ columns(0), columns(2..4), columns(7..11) ]
					center_columns.each do |r|
						r.style( align: :center )
					end

					header_cells = cells.columns(0..-1).rows(0)
					header_cells.background_color = "acacac"
					header_cells.size = 10
					header_cells.font_style = :bold
				end
			return pdf_data
		end
	end

	# OLD FORMAT
	def self.manifest(manifest)
		require "moji"

		infomart_raw_data = manifest.infomart_orders[:raw]
		informart_frozen_data = manifest.infomart_orders[:frozen]
		online_shop_raw_data = manifest.online_shop_orders[:raw]
		online_shop_frozen_data = manifest.online_shop_orders[:frozen]
		# 210mm x 297mm
		Prawn::Document.generate("PDF.pdf", :page_size => "A4", :page_layout => :landscape, :margin => [25]) do |pdf|
			#document set up
			pdf.font_families.update(PrawnPDF.fonts)
			#set utf-8 japanese font
			pdf.font "MPLUS1p"

			#first page for raw oysters
				#print the date
				pdf.font_size 14
				pdf.font "MPLUS1p", :style => :bold
				pdf.text  '生食用 InfoMart/WooCommerce 発送表' + ( ' ' * 94 ) + manifest.sales_date
				pdf.move_down 7
				pdf.font "MPLUS1p", :style => :normal

				#set up the data, make the header
				data_table = Array.new
				header_data_row = ['#', '注文者', 'お届け先', '500g', '1k', 'セル', '箱', 'お届け日', '時間', 'ナイフ', 'のし', '備考']
				data_table << header_data_row
				#add the rows
				i = 0
				used_row_count = 0
				#raw infomart orders
				infomart_raw_data.each do |order_id, order|
					order[:items].reverse_each do | item_number, details |
						if manifest.same_day(order) || manifest.two_days(order)
							order_data_row = Array.new
							used_row_count += 1
							# make a new array for this order row
							# order number
							if details[:item_name].exclude?("坂越バラ牡蠣") || ( details[:item_name].include?("坂越バラ牡蠣") && (order[:items].length < 2) )
								i += 1
								order_data_row << i
							else
								order_data_row << '↳'
							end
							#client name
							order_data_row << manifest.client_nicknames(order[:client])
							#recipent name
							order_data_row << '""'
							#500
							if details[:item_name].include?("500g")
								order_data_row << details[:item_count].to_s
							else
								order_data_row << ''
							end
							#1k
							if details[:item_name].include?("1k")
								order_data_row << '1k ×' + details[:item_count].to_s
							else
								order_data_row << ''
							end
							#shells
							if details[:item_name].include?("殻付き生牡蠣")
								if details[:item_count].to_i > 130
									order_data_row << '(' + details[:item_count].to_s + '個)'
								else
									order_data_row << details[:item_count].to_s + '個'
								end
							elsif details[:item_name].include?("坂越バラ牡蠣")
								order_data_row << 'バラ牡蠣' + details[:item_count].to_s + '㎏'
							else
								order_data_row << ''
							end
							#box
							order_data_row << 'YT-'
							#arrival date
							arrival = DateTime.strptime(order[:arrival][/\d.*\/+\d./].to_s, "%Y/%m/%d").strftime("%m月%d日")
							order_data_row << arrival
							#arrival time
							order_data_row << '午前　14-16'
							#knife
							order_data_row << ''
							#noshi
							order_data_row << ''
							#notes
							order_data_row << ''
							#add the array to the list of arrays that will become table rows
							data_table << order_data_row
							if details[:item_name].include?("殻付き生牡蠣") && details[:item_count].to_i > 130
								used_row_count += 1
								data_table << ['↳'] + [manifest.client_nicknames(order[:client])] + ['""'] + (['　'] * 2) + ['↳'] + ['YT-'] + [arrival] + ['午前　14-16'] + (['　'] * 3)
							end
						end
					end
				end
				#raw online shop orders
				online_shop_raw_data.each do |order_id, wc_order|
					i += 1
					ic = 0
					wc_order[:items].each do |item|
						if manifest.check_raw(item)
							count = manifest.wc_item_counts(item)
							order_data_row = Array.new
							used_row_count += 1
							#continue orer number
							order_data_row << if ic == 0 then i else '' end
							ic += 1
							# sender
							order_data_row << 'Ⓕ ' + manifest.wc_sender(wc_order)
							# recipient
							order_data_row << if manifest.wc_sender(wc_order) == manifest.wc_recipent(wc_order) then '""' else manifest.wc_recipent(wc_order) end
							# 500g mukimi
							mukimi500 = manifest.print_count(count)
							order_data_row << if !mukimi500.nil? then mukimi500 else '' end
							# 1k mukimi
							mukimi1k = manifest.print_count(count)
							order_data_row << if !mukimi1k.nil? then '1k × ' + mukimi1k else '' end
							# shells
							shells = manifest.print_count(count)
							order_data_row << (if !shells.nil? then shells + '個' else '' end) + (count[1].zero? ? "" : "小 #{count[1].to_s}㎏" )
							# box input
							order_data_row << 'YT-'
							# arrival date
							print_date = manifest.nengapi_to_gapi_date(Moji.zen_to_han(wc_order[:arrival_date]))
							order_data_row << print_date
							# arrival time
							order_data_row << if wc_order[:arrival_time] then wc_order[:arrival_time].gsub(':00', '') end
							# knife
							order_data_row << if item[:id] == 500 then item[:quantity] else '' end
							# noshi
							order_data_row << if (!wc_order[:noshi].nil? && wc_order[:noshi].exclude?('必要ない')) then wc_order[:noshi] else '' end
							# notes
							order_data_row << manifest.print_count(count)
							data_table << order_data_row
						end
					end
				end

				pdf.font_size 8
				pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :padding => 4 }, :column_widths => { 0 => 18, 1 => 100, 2 => 70, 3 => 50, 4 => 50, 5 => 100, 6 => 50, 7 => 50, 8 => 65, 9 => 50, 10 => 40 }, :width => 780 ) do
					rows(0..-1).each do |r|
						r.height = 20 if r.height < 20
					end

					cells.columns(1..2).rows(1..-1).font = "TakaoPMincho"

					center_columns = [ columns(0), columns(2..4), columns(7..11) ]
					center_columns.each do |r|
						r.style( align: :center )
					end

					header_cells = cells.columns(0..-1).rows(0)
					header_cells.background_color = "acacac"
					header_cells.size = 10
					header_cells.font_style = :bold
				end

				#Extra rows to fill up for raw orders
				data_table = Array.new
				fill_rows = pdf.page_count * 22
				(fill_rows - used_row_count).times { add_row(data_table, 12) }
				first_table_page_count = pdf.page_count
				if !data_table.empty?
					pdf.table( data_table, :cell_style => {:border_width => 0.25, :padding => 4 }, :column_widths => { 0 => 18, 1 => 100, 2 => 70, 3 => 50, 4 => 50, 5 => 100, 6 => 50, 7 => 50, 8 => 65, 9 => 50, 10 => 40 }, :width => 780 )
				end

			#second page for frozen oysters
				pdf.start_new_page
				#print the date
				pdf.font_size 14
				pdf.font "MPLUS1p", :style => :bold
				pdf.text  'プロトン凍結冷凍用 InfoMart/WooCommerce 発送表' + ( ' ' * 73 ) + manifest.sales_date
				pdf.move_down 7
				pdf.font "MPLUS1p", :style => :normal

				#set up the data, make the header
				data_table = Array.new
				header_data_row = ['#', '注文者', 'お届け先', '500g
					Lサイズ', '500g
					LLサイズ', '500g
					生食用WDI
					Lサイズ', 'セル', 'JPセル', 'お届け日', '時間', '備考']
				data_table << header_data_row
				#add the rows
				i = 0
				used_row_count = 0
				informart_frozen_data.each do | order_id, order |
					order[:items].each do | item_number, details |
						#if expected_arrival == order[:arrival][/\d.*\/+\d./] || order[:client].include?("ｏｃｅａｎ") || order[:client].include?("那覇")
						if manifest.same_day(order) || manifest.two_days(order)
						i += 1
						# make a new array for this order row
							order_data_row = Array.new
							used_row_count += 1
							# make a new array for this order row
							# order numner
							order_data_row << i
							#client name
							order_data_row << manifest.client_nicknames(order[:client])
							#recipent name
							order_data_row << '""'
							#500L
							if details[:item_name].include?("デカプリオイスター") && details[:item_name].exclude?("大粒") && details[:item_name].exclude?("LL") && details[:item_name].exclude?("岡山県産") && order[:client].exclude?("ブリーズオブ東京")  && order[:client].exclude?("オイスターバー品川店")
								order_data_row << ( if details[:item_name].include? "×20" then '20 × ' else '500g ×' end ) + details[:item_count]
							else
								order_data_row << ''
							end
							#500LL size
							if details[:item_name].include?("デカプリオイスター") && (details[:item_name].include?("大粒") or details[:item_name].include?("LL")) && order[:client].exclude?("ブリーズオブ東京") && order[:client].exclude?("オイスターバー品川店") or details[:item_name].include?("岡山県産") && details[:item_name].include?("デカプリオイスター")
								order_data_row << ( (details[:item_name].include? "岡山") ? ('㋔ ') : ('') ) + ( if details[:item_name].include? "×20" then '20 × ' + details[:item_count] elsif details[:item_name].include? "×10" then '10 × ' + details[:item_count] else '500g ×' + details[:item_count] end )
							else
								order_data_row << ''
							end
							#500LL WDI Raw
							if order[:client].include?("ブリーズオブ東京") || order[:client].include?("オイスターバー品川店")
								order_data_row << ( if details[:item_name].include? "×20" then '20 × ' else '500g ×' end ) + details[:item_count]
							else
								order_data_row << ''
							end
							#shells
							if details[:item_name].include?("冷凍殻付き牡蠣サムライオイスター")
								order_data_row << "#{'小 ' if details[:item_name].include?('小')}100個 × #{details[:item_count]}"
							elsif details[:item_name].include?("冷凍　殻付き牡蠣サムライオイスター")
								order_data_row << details[:item_count] + '個 × 1'
							else
								order_data_row << ''
							end
							#JP shells
							if details[:item_name].include?("生食用プロトンセル牡蠣120個")
								order_data_row << '120個 × ' + details[:item_count]
							else
								order_data_row << ''
							end
							#arrival date
							order_data_row << DateTime.strptime(order[:arrival][/\d.*\/+\d./].to_s, "%Y/%m/%d").strftime("%m月%d日")
							#arrival time
							order_data_row << '午前  14-16'
							#notes
							order_data_row << '                                               '
							#add the array to the list of arrays that will become table rows
							data_table << order_data_row
						end
					end
				end
				#frozen online ship orders
				online_shop_frozen_data.each do |order_id, wc_order|
					wc_order[:items].each do |item|
						if manifest.check_frozen(item)
							count = manifest.wc_item_counts(item)
							order_data_row = Array.new
							used_row_count += 1
							#continue orer number
							i += 1
							order_data_row << i
							# sender
							order_data_row << 'Ⓕ ' + manifest.wc_sender(wc_order)
							# recipient
							order_data_row << if manifest.wc_sender(wc_order) == manifest.wc_recipent(wc_order) then '""' else manifest.wc_recipent(wc_order) end
							# l size
							lsize = manifest.print_count(count)
							order_data_row << if !lsize.nil? then '500g × ' + lsize else '' end
							# ll size
							llsize = manifest.print_count(count)
							order_data_row << if !llsize.nil? then '500g × ' + llsize else '' end
							# wdi
							order_data_row << ''
							# shells
							rshells = manifest.print_count(count)
							order_data_row << if !rshells.nil? then rshells + '個' else '' end
							#JP spacer
							order_data_row << ''
							# arrival date
							print_date = manifest.nengapi_to_gapi_date(Moji.zen_to_han(wc_order[:arrival_date]))
							order_data_row << print_date
							# arrival times
							order_data_row << if wc_order[:arrival_time] then wc_order[:arrival_time].gsub(':00', '') end
							# notes
							order_data_row << if manifest.print_count(count).is_a?(String) then manifest.print_count(count) else '' end
							data_table << order_data_row
						end
					end
				end

				pdf.font_size 8
				pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :padding => 4}, :column_widths => { 0 => 18, 1 => 180, 2 => 50, 3 => 60, 4 => 60, 5 => 60, 6 => 55, 7 => 55, 8 => 55, 9 => 60 }, :width => 780 ) do
					rows(0..-1).each do |r|
						r.height = 20 if r.height < 20
					end

					cells.columns(1..2).rows(1..-1).font = "TakaoPMincho"

					center_columns = [ columns(0), columns(2..10) ]
					center_columns.each do |r|
						r.style( align: :center )
					end

					header_cells = cells.columns(0..-1).rows(0)
					header_cells.background_color = "acacac"
					header_cells.size = 10
					header_cells.font_style = :bold
				end

				#Extra rows to fill up the sheet for frozen
				data_table = Array.new
				fill_rows = (pdf.page_count - first_table_page_count) * 22
				(fill_rows - used_row_count).times { add_row(data_table, 11) }
				if !data_table.empty?
					pdf.table( data_table, :cell_style => {:border_width => 0.25, :padding => 4}, :column_widths => { 0 => 18, 1 => 180, 2 => 50, 3 => 60, 4 => 60, 5 => 60, 6 => 55, 7 => 55, 8 => 55, 9 => 60 }, :width => 780 )
				end
			return pdf
		end
	end

	def self.rakuten(rakuten, include_yahoo)
		data = rakuten.new_orders_hash.reverse

		if include_yahoo
			yahoo_orders = YahooOrder.where(ship_date: rakuten.date)

			def self.order_counts(orders)
				counts = Hash.new
				types_arr = %w{生むき身 生セル 小殻付 セルカード 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(80g) 干し殻付エビ(80g) タコ}
				types_arr.each {|w| counts[w] = 0}
				count_hash = {
					"kakiset302" => [2, 30, 0, 1, 0, 0, 0, 0, 0],
					"kakiset202" => [2, 20, 0, 1, 0, 0, 0, 0, 0],
					"kakiset301" => [1, 30, 0, 1, 0, 0, 0, 0, 0],
					"kakiset201" => [1, 20, 0, 1, 0, 0, 0, 0, 0],
					"kakiset101" => [1, 10, 0, 1, 0, 0, 0, 0, 0],
					"karatsuki100" => [0, 100, 0, 1, 0, 0, 0, 0, 0],
					"karatsuki50" => [0, 50, 0, 1, 0, 0, 0, 0, 0],
					"karatsuki40" => [0, 40, 0, 1, 0, 0, 0, 0, 0],
					"karatsuki30" => [0, 30, 0, 1, 0, 0, 0, 0, 0],
					"karatsuki20" => [0, 20, 0, 1, 0, 0, 0, 0, 0],
					"karatsuki10" => [0, 10, 0, 0, 0, 0, 0, 0, 0],
					"mukimi04" => [4, 0, 0, 0, 0, 0, 0, 0, 0],
					"mukimi03" => [3, 0, 0, 0, 0, 0, 0, 0, 0],
					"mukimi02" => [2, 0, 0, 0, 0, 0, 0, 0, 0],
					"mukimi01" => [1, 0, 0, 0, 0, 0, 0, 0, 0],
					"pkara100" => [0, 0, 0, 100, 0, 0, 0, 0, 0],
					"pkara50" => [0, 0, 0, 50, 0, 0, 0, 0, 0],
					"pkara40" => [0, 0, 0, 40, 0, 0, 0, 0],
					"pkara30" => [0, 0, 0, 30, 0, 0, 0, 0, 0],
					"pkara20" => [0, 0, 0, 20, 0, 0, 0, 0, 0],
					"pkara10" => [0, 0, 0, 10, 0, 0, 0, 0, 0],
					"pmuki04" => [0, 0, 1, 0, 0, 0, 0, 0, 0],
					"pmuki03" => [0, 0, 3, 0, 0, 0, 0, 0, 0],
					"pmuki02" => [0, 0, 2, 0, 0, 0, 0, 0, 0],
					"pmuki01" => [0, 0, 1, 0, 0, 0, 0, 0, 0],
					"tako1k" => [0, 0, 0, 0, 0, 0, 0, 0, 1],
					"mebi80x5" => [0, 0, 0, 0, 0, 0, 1, 0, 0],
					"mebi80x3" => [0, 0, 0, 0, 0, 0, 1, 0, 0],
					"hebi80x10" => [0, 0, 0, 0, 0, 0, 0, 1, 0],
					"hebi80x5" => [0, 0, 0, 0, 0, 0, 0, 1, 0],
					"anago600" => [0, 0, 0, 0, 1, 600, 0, 0, 0],
					"anago480" => [0, 0, 0, 0, 1, 480, 0, 0, 0],
					"anago350" => [0, 0, 0, 0, 1, 350, 0, 0, 0],
					"syoukara1kg" => [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
					"syoukara2kg" => [0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0],
					"syoukara3kg" => [0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0],
					"syoukara5kg" => [0, 0, 5, 1, 0, 0, 0, 0, 0, 0, 0]}
					orders.each do |order|
					unless order.order_status(false) == 4
						count_hash[order.item_id].each_with_index do |count, i|
							counts[types_arr[i]] += count
						end
					end
				end
				[counts.keys, counts.values]
			end
			continued_i = 0
			yahoo_counts = order_counts(yahoo_orders)
		end

		# 210mm x 297mm
		Prawn::Document.generate("PDF.pdf", :margin => [15]) do |pdf|
			pdf.font_families.update(PrawnPDF.fonts)
			#set utf-8 japanese font
			pdf.font "MPLUS1p"

			#print the date
			pdf.font_size 16
			pdf.font "MPLUS1p", :style => :bold
			pdf.text rakuten.sales_date + " 楽天市場#{'とヤフーショッピング' if include_yahoo} 発送表"
			pdf.move_down 15
			pdf.font "MPLUS1p", :style => :normal

			counts = rakuten.new_order_counts
			work_totals = rakuten.prep_work_totals
			if include_yahoo
				work_totals[:shell_cards] += yahoo_counts[1][3]
				counts[:mizukiri] += yahoo_counts[1][0]
				counts[:shells] += yahoo_counts[1][1]
				counts[:dekapuri] += yahoo_counts[1][4]
				counts[:reitou_shells] += yahoo_counts[1][5]
				counts[:anago] += yahoo_counts[1][6]
				counts[:tako] += yahoo_counts[1][10]
				counts[:ebi] += (yahoo_counts[1][8] + yahoo_counts[1][9])
				work_totals[:knife_count] += yahoo_counts[1][3]
			end
			counts_table = Array.new
			counts_table << ['むき身', "セル (#{work_totals[:shell_cards]}枚）", 'デカプリ', '冷凍セル', '穴子', 'タコ', '干しエビ', 'ナイフ']
			counts_table << [counts[:mizukiri].to_s + '　<font size="6">パック</font>',
							"#{counts[:shells].to_s}　<font size='6'>個</font>　・　#{counts[:barakara].to_s}　<font size='6'>kg</font>",
							counts[:dekapuri].to_s + '　<font size="6">パック</font>',
							counts[:reitou_shells].to_s + '　<font size="6">個</font>',
							counts[:anago].to_s + '　<font size="6">件</font>',
							counts[:tako].to_s + '　<font size="6">件</font>',
							counts[:ebi].to_s + '　<font size="6">件</font>',
							work_totals[:knife_count].to_s + '　<font size="6">個</font>']
			pdf.table( counts_table, :cell_style => {:inline_format => true, :border_width => 0.25, :valign => :center, :align => :center, :size => 10}, :width => pdf.bounds.width ) do |t|
				t.row(0).background_color = "acacac"
			end
			pdf.move_down 10

			#set up the data, make the header
			data_table = Array.new
			header_data_row = ['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']
			data_table << header_data_row

			data.each_with_index do |order, i|
				if order.is_a?(Hash)
					# make a new array for this order row
					order_data_row = Array.new
					# order numner
					order_data_row << i + 1
					# sender and reciever
					sender_name = order[:sender]['familyName'].to_s + ' ' + order[:sender]['firstName'].to_s
					order_data_row << sender_name
					recipient_names = String.new
					order[:recipient].each do |recipient_name|
						if sender_name == recipient_name
							recipient_names << '""
							'
						else
							recipient_names << recipient_name + '
							'
						end
					end
					order_data_row << recipient_names
					#mizukiri
					if !order[:mizukiri][:amount].nil?
						text = ''
						order[:mizukiri][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
							 ' end
							text += amount.to_s
							if order[:mizukiri][:count][i] > 1 then text += '× ' + order[:mizukiri][:count][i].to_s + '!' end
						end
						order_data_row << text
					end
					#shells
					if !order[:shells][:amount].nil? && !order[:barakara][:amount].nil?
						text = ''
						order[:shells][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
								' end
							text += "#{amount.to_s}#{'個' if !order[:barakara][:amount].nil?} "
							if order[:shells][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
						end
						order[:barakara][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
								' end
							text += "#{amount.to_s}㎏ "
							if order[:barakara][:count][i] > 1 then text += '× ' + order[:barakara][:count][i].to_s + '!' end
						end
						order_data_row << text
					end
					#sets
					if !order[:sets][:amount].nil?
						text = ''
						order[:sets][:amount].each_with_index do |amount, i|
							if i > 0 then text += '
								' end
							text += '500g×' + amount.to_s.scan(/\d(?!.*\d)/).first + ' + ' + amount.to_s.scan(/\d{2}/).first + '個'
							if order[:sets][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
						end
						order_data_row << text
					end
					#others
					others_text = ''
						if !order[:tako][:amount].nil?
							order[:tako][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += 'ボイルたこ (~1㎏)' + amount.to_s
								if order[:tako][:count][i] > 1 then others_text += '× ' + order[:tako][:count][i].to_s + '!' end
							end
						end
						if !order[:karaebi80g][:amount].nil?
							order[:karaebi80g][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '干しエビ（殻付き）80g×' + amount.to_s
								if order[:karaebi80g][:count][i] > 1 then others_text += '× ' + order[:karaebi80g][:count][i].to_s + '!' end
							end
						end
						if !order[:mukiebi80g][:amount].nil?
							order[:mukiebi80g][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '干しエビ（むき身）80g×' + amount.to_s
								if order[:mukiebi80g][:count][i] > 1 then others_text += '× ' + order[:mukiebi80g][:count][i].to_s + '!' end
							end
						end
						if !order[:anago][:amount].nil?
							order[:anago][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '穴子' + amount.to_s + 'g'
								if order[:anago][:count][i] > 1 then others_text += '× ' + order[:anago][:count][i].to_s + '!' end
							end
						end
						if !order[:dekapuri][:amount].nil?
							order[:dekapuri][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '冷凍500g×' + amount.to_s
								if order[:dekapuri][:count][i] > 1 then others_text += '× ' + order[:dekapuri][:count][i].to_s + '!' end
							end
						end
						if !order[:reitou_shell][:amount].nil?
							order[:reitou_shell][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += '冷凍セル' + amount.to_s + '個'
								if order[:reitou_shell][:count][i] > 1 then others_text += '× ' + order[:reitou_shell][:count][i].to_s + '!' end
							end
						end
						if !order[:kakita][:amount].nil?
							order[:kakita][:amount].each_with_index do |amount, i|
								if i > 0 then others_text += '
									' end
								others_text += 'カキータ×' + amount.to_s
								if order[:kakita][:count][i] > 1 then others_text += '× ' + order[:kakita][:count][i].to_s + '!' end
							end
						end
					order_data_row << others_text
					#arrival date
					def self.date_check(rakuten, order)
						if (DateTime.strptime(rakuten.sales_date, "%Y年%m月%d日") + 1) == (DateTime.strptime(order[:arrival_date], "%Y-%m-%d"))
							'明日着'
						else
							(DateTime.strptime(order[:arrival_date], "%Y-%m-%d")).strftime('%m月%d日')
						end
					end
					order_data_row << date_check(rakuten, order)
					#arrival time
					order_data_row << if order[:arrival_time] == 'なし' then '' else order[:arrival_time] end
					#knife
					knife_count = 0
					if !order[:knife][:amount].nil?
						order[:knife][:amount].each_with_index do |amount, i|
							knife_count += order[:knife][:count][i]
						end
					end
					if knife_count > 1 then order_data_row << knife_count.to_s elsif knife_count > 0 then order_data_row << '✓' else order_data_row << '' end
					#noshi
					if order[:noshi] == true then order_data_row << '✓' else order_data_row << '' end
					#receipt
					remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first.gsub(/\n/, '')
					if order[:notes].nil? then notes = '' else notes = order[:notes] end
					if !order[:receipt].nil? then order_data_row << order[:receipt] elsif remarks.include?('領収') || notes.include?('領収') then order_data_row << '✓' else order_data_row << '' end
					#notes
					collect = (order[:payment_method] == "代金引換") ? '代引：￥' + order[:charged_cost].to_s : ''
					order_data_row << remarks + collect
					#add the array to the list of arrays that will become table rows
					data_table << order_data_row
					if include_yahoo
						continued_i = (i + 2)
					end
				end
			end
			if include_yahoo

				data_table << [' ', 'ヤフー↓'] + ([''] * 11)

				def self.print_items(order)
					print_array = {
						"kakiset302" => ["", "", "500g×2 + 30個", ""],
						"kakiset202" => ["", "", "500g×2 + 20個", ""],
						"kakiset301" => ["", "", "500g×1 + 30個", ""],
						"kakiset201" => ["", "", "500g×1 + 20個", ""],
						"kakiset101" => ["", "", "500g×1 + 10個", ""],
						"karatsuki100" => ["", "100個", "", ""],
						"karatsuki50" => ["", "50個", "", ""],
						"karatsuki40" => ["", "40個", "", ""],
						"karatsuki30" => ["", "30個", "", ""],
						"karatsuki20" => ["", "20個", "", ""],
						"karatsuki10" => ["", "10個", "", ""],
						"syoukara1kg" => ["", "小1㎏", "", ""],
						"syoukara2kg" => ["", "小2㎏", "", ""],
						"syoukara3kg" => ["", "小3㎏", "", ""],
						"syoukara5kg" => ["", "小5㎏", "", ""],
						"mukimi04" => ["4", "", "", ""],
						"mukimi03" => ["3", "", "", ""],
						"mukimi02" => ["2", "", "", ""],
						"mukimi01" => ["1", "", "", ""],
						"pkara100" => ["", "", "", "冷凍セル 100個"],
						"pkara50" => ["", "", "", "冷凍セル 50個"],
						"pkara40" => ["", "", "", "冷凍セル 40個"],
						"pkara30" => ["", "", "", "冷凍セル 30個"],
						"pkara20" => ["", "", "", "冷凍セル 20個"],
						"pkara10" => ["", "", "", "冷凍セル 10個"],
						"pmuki04" => ["", "", "", "冷凍500g×4"],
						"pmuki03" => ["", "", "", "冷凍500g×3"],
						"pmuki02" => ["", "", "", "冷凍500g×2"],
						"pmuki01" => ["", "", "", "冷凍500g×1"],
						"tako1k" => ["", "", "", "ボイルたこ"],
						"mebi80x5" => ["", "", "", "干しむきエビ 80gx5"],
						"mebi80x3" => ["", "", "", "干しむきエビ 80gx3"],
						"hebi80x10" => ["", "", "", "干し殻付エビ 80gx10"],
						"hebi80x5" => ["", "", "", "干し殻付エビ 80gx5"],
						"anago600" => ["", "", "", "焼き穴子600g"],
						"anago480" => ["", "", "", "焼き穴子480g"],
						"anago350" => ["", "", "", "焼き穴子350g"] }
					print_array[order.item_id]
				end

				yahoo_orders.each_with_index do |yahoo_order, i|
					item = print_items(yahoo_order)
					order_arr = ["#{continued_i + i}
						(#{i + 1})"]
					order_arr << yahoo_order.billing_name
					order_arr << (yahoo_order.billing_name == yahoo_order.shipping_name ? '""' : yahoo_order.shipping_name)
					item.each do |item|
						order_arr << (item.empty? ? item : (item + yahoo_order.print_quantity))
					end
					order_arr << yahoo_order.shipping_arrival_date.strftime("%Y/%m/%d")
					order_arr << yahoo_order.arrival_time
					order_arr << ""
					order_arr << ""
					order_arr << ""
					order_arr << ""
					data_table << order_arr
				end
			end

			data_table << ['　'] * 13
			data_table << ['　'] * 13
			data_table << ['　'] * 13
			data_table << ['　'] * 13
			data_table << ['　'] * 13
			pdf.font_size 8
			pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :valign => :center}, :column_widths => {0 => 18, 1 => 55, 2 => 55, 3 => 30, 4 => 27, 5=> 50, 12=> 100}, :width => pdf.bounds.width ) do

				cells.column(0).rows(1..-1).padding = 2
				cells.columns(1..2).rows(1..-1).font = "TakaoPMincho"
				cells.columns(1..-1).rows(1..-1).padding = 4

				header_cells = cells.columns(0..12).rows(0)
				header_cells.background_color = "acacac"
				header_cells.size = 7
				header_cells.font_style = :bold

				cells.columns(7).rows(1..-1).font_style = :light

				set_other_time_cells = cells.columns([5, 6, 7, 8, 12]).rows(1..-1)
				set_other_time_cells.size = 7

				item_cells = cells.columns(3..6).rows(1..-1)
				multi_cells = item_cells.filter do |cell|
					cell.content.to_s[/!/]
				end
				multi_cells.background_color ="ffc48f"

				item_cells = cells.columns(9..11).rows(1..-6)
				check_cells = item_cells.filter do |cell|
					!cell.content.to_s.empty?
				end
				check_cells.background_color ="ffc48f"


				note_cells = cells.columns(12).rows(1..-1)
				cash_cells = note_cells.filter do |cell|
					cell.content.to_s[/代引/]
				end
				cash_cells.background_color ="ffc48f"

				date_cells = cells.columns(7).rows(1..-1)
				not_tomorrow_cells = date_cells.filter do |cell|
					cell.content.to_s[/月/]
				end
				not_tomorrow_cells.background_color ="ffc48f"
			end
			return pdf
		end
	end

	def self.rakuten_seperated(rakuten)
		intital_data = rakuten.new_orders_hash.reverse
		unless intital_data.empty?
			data = Hash.new
			knife_data = Hash.new
			order_types = [:mizukiri, :shells, :sets]
			other_types = [:dekapuri, :karaebi80g, :mukiebi80g, :anago, :reitou_shell, :tako, :kakita, :barakara]
			all_types = order_types.push(*other_types)
			intital_data.each_with_index do |order, i|
				(i == 0) ? data[:knife] = Hash.new : ()
				order_types.each do |t|
					(i == 0) ? (data[t] = Set.new) : ()
					if order[:knife][:count].empty?
						!order[t][:count].empty? ? data[t] << i : ()
					end
				end
				order_types.each do |t|
					(i == 0) ? (knife_data[t] = Set.new) : ()
					if !order[:knife][:count].empty?
						!order[t][:count].empty? ? knife_data[t] << i : ()
					end
				end
				other_types.each do |t|
					(i == 0) ? (data[t] = Set.new) : ()
					!order[t][:count].empty? ? data[t] << i : ()
				end
			end
			new_set = Hash.new
			new_knife = Hash.new
			value_set = Hash.new
			knife_value_set = Hash.new
			final = Hash.new
			final_knife = Hash.new
			order_types.each do |t|
				new_set[t] = Hash.new
				new_knife[t] = Hash.new
				value_set[t] = Set.new
				knife_value_set[t] = Set.new
				if !data[t].nil? || !data[t].empty?
					data[t].each do |n|
						if !intital_data[n][t][:count].empty?
							value_set[t] << intital_data[n][t][:amount]
							amount = intital_data[n][t][:amount]
							new_set[t][amount].nil? ? new_set[t][amount] = Array.new : ()
							new_set[t][amount] << n
						end
					end
				end
				if !knife_data[t].empty?
					knife_data[t].each do |n|
						if !intital_data[n][t][:count].empty?
							knife_value_set[t] << intital_data[n][t][:amount]
							amount = intital_data[n][t][:amount]
							new_knife[t][amount].nil? ? new_knife[t][amount] = Array.new : ()
							new_knife[t][amount] << n
						end
					end
				end
			end
			order_types.each do |t|
				final[t] = Array.new
				value_set[t].sort.reverse.each do |v|
					final[t].push(*new_set[t][v])
				end
				final_knife[t] = Array.new
				knife_value_set[t].sort.reverse.each do |v|
					final_knife[t].push(*new_knife[t][v])
				end
			end
			# 210mm x 297mm
			Prawn::Document.generate("PDF.pdf", :margin => [15]) do |pdf|
				pdf.font_families.update(PrawnPDF.fonts)
				#set utf-8 japanese font
				pdf.font "MPLUS1p", :style => :normal
				header_data_row = ['#', '注文者', '送付先', '500g', 'セル', 'セット', 'その他', 'お届け日', '時間', 'ナイフ', 'のし', '領収書', '備考']
				translation_hash = {:mizukiri => "水切り", :shells => "セル", :sets => "セット", :dekapuri => "デカプリオイスター", :karaebi80g => "干しエビ（殻付き）80g", :mukiebi80g => "干しエビ（むき身）80g", :anago => "穴子", :reitou_shell => "冷凍せ", :tako => "ボイルたこ (~1㎏)", :kakita => "カキータ", barakara: "小殻付き"}
				[final, final_knife].each_with_index do |data_set, mi|
					all_types.each_with_index do |type, i|
						if !data_set[type].empty? && !data_set[type].nil?
							(i != 0 || mi != 0) ? (pdf.start_new_page) : ()
							data_table = Array.new
							knife_text = (data_set == final_knife) ? ('+ ナイフ') : ('')
							data_table << [ {:content =>  "発送日:　<b>#{rakuten.sales_date}</b>", :colspan => 5}, {:content => "商品区別:　<b>#{translation_hash[type] + knife_text}</b>", :colspan => 5}, {:content => "印刷日:　<b>#{DateTime.now.strftime("%Y年%m月%d日")}</b>", :colspan => 3}]
							data_table << header_data_row
							data_set[type].each do |local_order_number|
								order = intital_data[local_order_number]
								if order.is_a?(Hash)
									# make a new array for this order row
									order_data_row = Array.new
									# order number
									order_data_row << (local_order_number + 1).to_s
									# sender and reciever
									sender_name = order[:sender]['familyName'].to_s + ' ' + order[:sender]['firstName'].to_s
									order_data_row << sender_name
									recipient_names = String.new
									order[:recipient].each do |recipient_name|
										if sender_name == recipient_name
											recipient_names << '""
											'
										else
											recipient_names << recipient_name + '
											'
										end
									end
									order_data_row << recipient_names
									#mizukiri
									if !order[:mizukiri][:amount].nil?
										text = ''
										order[:mizukiri][:amount].each_with_index do |amount, i|
											if i > 0 then text += '
												' end
											text += amount.to_s
											if order[:mizukiri][:count][i] > 1 then text += '× ' + order[:mizukiri][:count][i].to_s + '!' end
										end
										order_data_row << text
									end
									#shells
									if !order[:shells][:amount].nil?
										text = ''
										order[:shells][:amount].each_with_index do |amount, i|
											if i > 0 then text += '
												' end
											text += amount.to_s
											if order[:shells][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
										end
										order_data_row << text
									end
									#sets
									if !order[:sets][:amount].nil?
										text = ''
										order[:sets][:amount].each_with_index do |amount, i|
											if i > 0 then text += '
												' end
											text += '500g×' + amount.to_s.scan(/\d(?!.*\d)/).first + ' + ' + amount.to_s.scan(/\d{2}/).first + '個'
											if order[:sets][:count][i] > 1 then text += '× ' + order[:shells][:count][i].to_s + '!' end
										end
										order_data_row << text
									end
									#others
									others_text = ''
										if !order[:tako][:amount].nil?
											order[:tako][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '
													' end
												others_text += 'ボイルたこ (~1㎏)×' + amount.to_s
												if order[:tako][:count][i] > 1 then others_text += '× ' + order[:tako][:count][i].to_s + '!' end
											end
										end
										if !order[:karaebi80g][:amount].nil?
											order[:karaebi80g][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '
													' end
												others_text += '干しエビ（殻付き）80g×' + amount.to_s
												if order[:karaebi80g][:count][i] > 1 then others_text += '× ' + order[:karaebi80g][:count][i].to_s + '!' end
											end
										end
										if !order[:mukiebi80g][:amount].nil?
											order[:mukiebi80g][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '
													' end
												others_text += '干しエビ（むき身）80g×' + amount.to_s
												if order[:mukiebi80g][:count][i] > 1 then others_text += '× ' + order[:mukiebi80g][:count][i].to_s + '!' end
											end
										end
										if !order[:anago][:amount].nil?
											order[:anago][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '
													' end
												others_text += '穴子' + amount.to_s + 'g'
												if order[:anago][:count][i] > 1 then others_text += '× ' + order[:anago][:count][i].to_s + '!' end
											end
										end
										if !order[:dekapuri][:amount].nil?
											order[:dekapuri][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '
													' end
												others_text += '冷凍500g×' + amount.to_s
												if order[:dekapuri][:count][i] > 1 then others_text += '× ' + order[:dekapuri][:count][i].to_s + '!' end
											end
										end
										if !order[:reitou_shell][:amount].nil?
											order[:reitou_shell][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '
													' end
												others_text += '冷凍セル' + amount.to_s + '個'
												if order[:reitou_shell][:count][i] > 1 then others_text += '× ' + order[:reitou_shell][:count][i].to_s + '!' end
											end
										end
										if !order[:kakita][:amount].nil?
											order[:kakita][:amount].each_with_index do |amount, i|
												if i > 0 then others_text += '  -
													' end
												others_text += 'カキータ×' + amount.to_s
												if order[:kakita][:count][i] > 1 then others_text += '× ' + order[:kakita][:count][i].to_s + '!' end
											end
										end
									order_data_row << others_text
									#arrival date
									def self.date_check(rakuten, order)
										if (DateTime.strptime(rakuten.sales_date, "%Y年%m月%d日") + 1) == (DateTime.strptime(order[:arrival_date], "%Y-%m-%d"))
											'明日着'
										else
											(DateTime.strptime(order[:arrival_date], "%Y-%m-%d")).strftime('%m月%d日')
										end
									end
									order_data_row << date_check(rakuten, order)
									#arrival time
									order_data_row << if order[:arrival_time] == 'なし' then '' else order[:arrival_time] end
									#knife
									knife_count = 0
									if !order[:knife][:amount].nil?
										order[:knife][:amount].each_with_index do |amount, i|
											knife_count += order[:knife][:count][i]
										end
									end
									if knife_count > 1 then order_data_row << knife_count.to_s elsif knife_count > 0 then order_data_row << '✓' else order_data_row << '' end
									#noshi
									if order[:noshi] == true then order_data_row << '✓' else order_data_row << '' end
									#receipt
									remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first.gsub(/\n/, '')
									if order[:notes].nil? then notes = '' else notes = order[:notes] end
									if !order[:receipt].nil? then order_data_row << order[:receipt] elsif remarks.include?('領収') || notes.include?('領収') then order_data_row << '✓' else order_data_row << '' end
									#notes
									collect = (order[:payment_method] == "代金引換") ? '代引：￥' + order[:charged_cost].to_s : ''
									order_data_row << remarks + collect
									#add the array to the list of arrays that will become table rows
									data_table << order_data_row
								end
							end
							data_table << ['　'] * 13
							data_table << ['　'] * 13
							data_table << ['　'] * 13
							data_table << ['　'] * 13
							data_table << ['　'] * 13
							pdf.font_size 8
							pdf.table( data_table, :header => true, :cell_style => {:border_width => 0.25, :valign => :center, :inline_format => true}, :column_widths => {0 => 18, 1 => 55, 2 => 55, 3 => 25, 4 => 22, 5=> 50, 10 => 30, 11 => 30, 12=> 100}, :width => pdf.bounds.width ) do

								cells.row(0).padding = 7
								cells.column(0).rows(1..-1).padding = 2
								cells.columns(1..-1).rows(1..-1).padding = 4

								header_cells = cells.columns(0..12).rows(1)
								header_cells.background_color = "acacac"
								header_cells.size = 7
								header_cells.font_style = :bold

								cells.columns(7).rows(1..-1).font_style = :light

								set_other_time_cells = cells.columns([5, 6, 7, 8, 12]).rows(1..-1)
								set_other_time_cells.size = 7

								item_cells = cells.columns(3..6).rows(1..-1)
								multi_cells = item_cells.filter do |cell|
									cell.content.to_s[/!/]
								end
								multi_cells.background_color ="ffc48f"

								item_cells = cells.columns(9..11).rows(2..-6)
								check_cells = item_cells.filter do |cell|
									!cell.content.to_s.empty?
								end
								check_cells.background_color ="ffc48f"


								note_cells = cells.columns(12).rows(1..-1)
								cash_cells = note_cells.filter do |cell|
									cell.content.to_s[/代引/]
								end
								cash_cells.background_color ="ffc48f"

								date_cells = cells.columns(7).rows(1..-1)
								not_tomorrow_cells = date_cells.filter do |cell|
									cell.content.to_s[/月/]
								end
								not_tomorrow_cells.background_color ="ffc48f"
							end
						end
					end
				end
				#output the pdf
				return pdf
			end
		else
			Prawn::Document.generate("PDF.pdf", :margin => [15]) do |pdf|
				pdf.font_families.update(PrawnPDF.fonts)
				#set utf-8 japanese font
				pdf.font "MPLUS1p", :style => :normal
				pdf.text '発送なし'
				return pdf
			end
		end
	end

	def self.reciept(options)
		options[:oysis].to_i.zero? ? oysis = false : oysis = true
		if oysis
			unless options[:order_id].nil? || !options[:order_id].is_a?(Integer)
				options[:order_id].empty? ? order = nil : order = RManifest.find(options[:order_id]).new_orders_hash.reverse[options[:order_id].to_i]
			end
		else
			order = nil
		end
		!order.nil? ? (remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first) : remarks = ''
		options[:title].nil? ? title = '様' : title = options[:title]
		options[:expense_name].empty? ? expense = 'お品代として' : expense = options[:expense_name]
		if options[:purchaser].empty?
			if order.nil?
				purchaser = ''
			else
				purchaser = order[:sender]["familyName"]
			end
		else
			purchaser = options[:purchaser]
		end
		if options[:amount].empty?
			if order.nil?
				amount = ''
			else
				amount = order[:final_cost]
			end
		else
			amount = options[:amount]
		end
		oyster_sisters_info = "株式会社船曳商店 　
		OYSTER SISTERS
		〒678-0232
		兵庫県赤穂市中広1576－11
		TEL: 0791-42-3645
		FAX: 0791-43-8151
		店舗運営責任者: 船曳　晶子"
		company_info = "株式会社船曳商店 　
		〒678-0232
		兵庫県赤穂市中広1576－11
		TEL: 0791-42-3645
		FAX: 0791-43-8151
		メール: info@funabiki.info
		ウエブ: www.funabiki.info"
		oyster_sisters_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/Oyster%20Sisters%202.jpg")
		oysis_logo_cell = {image: oyster_sisters_logo, :scale => 0.08, colspan: 1, rowspan: 3, :position  => :center, :vposition => :center}
		funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")
		logo_cell = {:image => funabiki_logo, :scale => 0.05, colspan: 1, rowspan: 3, :position  => :center, :vposition => :center }
		receipt_date = options[:sales_date]

		# Make the PDF
		Prawn::Document.generate("PDF.pdf", page_size: "A5", :margin => [15]) do |pdf|
			pdf.font_families.update(PrawnPDF.fonts)

			#set utf-8 japanese font
			pdf.font "TakaoPMincho"
			pdf.font_size 10
			pdf.move_down 10
			receipt_table = Array.new
			receipt_table << [{content: '   領   収   証   ', colspan: 3, size: 17, align: :center}]
			receipt_table << [{content: '<u>  ' + purchaser + '  ' + title + '  </u>' , colspan: 2, size: 14, align: :center}, {content: receipt_date, colspan: 1, size: 10, align: :center}]
			receipt_table << [{content: '★', size: 10, align: :center}, {content: '<font size="18">￥ ' + ApplicationController.helpers.yenify(amount) + '</font>', size: 10, align: :center}, {content: '★', size: 10, align: :center}]
			receipt_table << [{content: '但 ' + expense + '<br>上  記  正  に  領  収  い  た  し  ま  し  た', size: 10, align: :center, valign: :bottom, colspan: 3}]
			if oysis
				receipt_table << [{content: '内　　訳', colspan: 1}, oysis_logo_cell, {content: oyster_sisters_info, colspan: 1, rowspan: 3, size: 8}]
			else
				receipt_table << [{content: '内　　訳', colspan: 1}, logo_cell, {content: company_info, colspan: 1, rowspan: 3, size: 8}]
			end
			receipt_table << [{content: '税抜金額', colspan: 1}]
			receipt_table << [{content: '消費税額等（     ％）', colspan: 1}]

			2.times do |i|
				pdf.table(receipt_table, cell_style: {inline_format: true, valign: :center, padding: 10}, width: pdf.bounds.width, column_widths: {0..3 => (pdf.bounds.width/3)} ) do |t|
					t.cells.borders = [:top, :left, :right, :bottom]
					t.cells.border_width = 0
					t.row(0).border_top_width = 0.25
					t.row(-1).border_bottom_width = 0.25
					t.column(0).border_left_width = 0.25
					t.column(-1).border_right_width = 0.25

					t.row(1).border_top_width = 0.25
					t.row(1).border_bottom_width = 0.25
					t.row(2).border_bottom_width = 0.25
					t.row(2).border_lines = [:dotted, :solid, :dotted, :solid]
					t.row(1).border_lines = [:dotted, :solid, :dotted, :solid]

					t.row(2).background_color = 'EEEEEE'

					t.row(-2).column(0).border_bottom_width = 0.25
					t.row(-3).column(0).border_bottom_width = 0.25
					t.row(-2).column(0).border_lines = [:dotted, :solid, :dotted, :solid]
					t.row(-3).column(0).border_lines = [:dotted, :solid, :dotted, :solid]
				end
				i == 0 ? (pdf.move_down 40) : ()
			end
			oyster_sisters_logo.close
			funabiki_logo.close
			return pdf
		end
	end

	def self.set_supply_variables
		@sakoshi_suppliers = Supplier.where(location: '坂越').order(:supplier_number)
		@aioi_suppliers = Supplier.where(location: '相生').order(:supplier_number)
		@all_suppliers = @sakoshi_suppliers + @aioi_suppliers
		@receiving_times = ["am", "pm"]
		@supplier_numbers = @sakoshi_suppliers.pluck(:id).map(&:to_s)
		@supplier_numbers += @aioi_suppliers.pluck(:id).map(&:to_s)
		@types = ["large", "small", "eggy", "large_shells", "small_shells", "thin_shells"]
	end

	def self.oyster_supply_check(supply)
		set_supply_variables
		am_or_pm = ["午前", "午後"]
		funabiki_info = {:content => "<b>〒678-0232 </b>
		兵庫県赤穂市1576－11
		(株)船曳商店
		TEL (0791)43-6556 FAX (0791)43-8151
		メール info@funabiki.info", :size => 8, :padding => 3, :colspan => 3}
		funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")
		logo_cell = {:image => funabiki_logo, :scale => 0.065, :colspan => 4, :position  => :center }
		created_info = {:content => '<b><font size="12">作成日・更新日</font></b>
		2019年05月31日
		2019年04月02日', :size => 10, :padding => 3, :colspan => 3, :align => :right}
		darker = 'cfcfcf'
		guidelines = '〇＝適切　X＝不適切
		不適切な場合は備考欄に日付と説明を
		書いてください。'
		require "prawn"
		require "open-uri"
		Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [15]) do |pdf|
			# document set up
			pdf.font_families.update(PrawnPDF.fonts)
			# set utf-8 japanese font
			pdf.font "MPLUS1p"
			pdf.font_size 10
			am_or_pm.each_with_index do |am_or_pm, i|
				if i != 0
					pdf.start_new_page
				end
				table_data = Array.new
				table_data << [{:content => guidelines, :colspan => 3, :rowspan => 3, :size => 9, :align => :center, :valign => :center}, {:content => "(マガキ)生牡蠣原料受入表①（兵庫県産）", :colspan => 5, :rowspan => 3, :size => 14, :padding => 7, :align => :center, :valign => :center, :font_style => :bold}, {:content => "確認日付", :colspan => 2, :size => 7, :padding => 1, :align => :left, :valign => :center}]
				table_data << ["社長", "品管"]
				table_data << [{:content => " <br> ", :padding => 3}, {:content => " <br> ", :padding => 3}]
				table_data << [{:content => "", :colspan => 10, :padding => 2}]
				table_data << [ {:content => supply.supply_date, :colspan => 5, :size => 10, :align => :center}, {:content => am_or_pm, :colspan => 2, :size => 10, :align => :center}, {:content => "時刻:", :colspan => 3, :size => 10, :align => :left}]
				table_data << ["海域", {:content => "生産者", :font => "TakaoPMincho"}, "数量(kg)", "セル数", "官能検査", "温度(℃)", "pH", "塩分(%)", "最終判定", "確認者"]
				suppliers = [@sakoshi_suppliers, @aioi_suppliers]
				suppliers.each do |area_suppliers|
					large_total = 0
					small_total = 0
					area_suppliers.each do |s|
						large_total += supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "large", s.id.to_s, "subtotal").to_f
						small_total += supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "small", s.id.to_s, "subtotal").to_f
					end
					area_suppliers.each_with_index do |supplier, i|
						large_subtotal = supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "large", supplier.id.to_s, "subtotal").to_f
						small_subtotal = supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "small", supplier.id.to_s, "subtotal").to_f
						large_shell_subtotal = supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "large_shells", supplier.id.to_s, "0").to_i
						small_shell_subtotal = supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "small_shells", supplier.id.to_s, "0").to_i
						thin_shell_subtotal = supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "thin_shells", supplier.id.to_s, "0").to_i
						darken = (large_subtotal + small_subtotal + large_shell_subtotal + small_shell_subtotal + thin_shell_subtotal).zero?
						supplier_top_row = Array.new
						if i == 0
							supplier_top_row << { :content => supplier.location[0] + "<br>" + supplier.location[1] + "<font size='11'><br><br>大<br>" + large_total.to_s + "<br><br>小<br>" + small_total.to_s + "</font>", :rowspan => (area_suppliers.length * 2), :size => 28, :valign => :center, :align => :center}
						end
						#set up totals for shucked oysters
						supplier_top_row << { :content => supply.number_to_circular(supplier.supplier_number.to_s), :size => 11, :align => :center, background_color: (darken ? darker : 'ffffff')}
						supplier_total = (supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "large", supplier.id.to_s, "subtotal").to_f + supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "small", supplier.id.to_s, "subtotal").to_f + supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "eggy", supplier.id.to_s, "subtotal").to_f).to_s
						#set up totals for shells
						shells = Array.new
						shells << (supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "large_shells", supplier.id.to_s, "0").to_i + supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "small_shells", supplier.id.to_s, "0").to_i).to_s
						shells << supply.oysters.dig(supply.kanji_am_pm(am_or_pm), "thin_shells", supplier.id.to_s, "0")
						supplier_top_row.push({:content => '<font size="7">合計  </font><b>' + (darken ? 'なし' : supplier_total) + "<b>", :size => 9}, {:content => (darken ? 'なし' : (shells.join("個／") + "kg")), size: 7, :align => :center}, "", {:content => "℃", :align => :right, :size => 7}, "", {:content => "%", :align => :right, :size => 7}, "", "")
						supplier_buckets = Array.new
						bucket_types = ["large", "small", "eggy"]
						bucket_types.each do |type|
							6.times do |i|
								this_bucket = supply.oysters.dig(supply.kanji_am_pm(am_or_pm), type, supplier.id.to_s, i.to_s).to_s
								supplier_buckets << this_bucket
							end
						end
						supplier_buckets.reject! {|x| x == "0" || x == ""}
						supplier_bottom_row = [{ :content => supplier.company_name, :size => 7, :align => :center, :padding => 1, :font => "TakaoPMincho", background_color: (darken ? darker : 'ffffff') }, { :content => supplier_buckets.join("　　") + " ", :colspan => 6, :size => 8, :font_style => :light}, { :content => ":数量小計/備考", :colspan => 1, :size => 6, :padding => 1, :align => :right, valign: :center}, '']
						table_data << supplier_top_row
						table_data << supplier_bottom_row
					end
				end
				guidelines_one = "●記録の頻度
					入荷ごとに海域および生産者別に行う。
					●備考欄に生産者の牡蠣の質・状態についての一言を記入する、または 最終判定が×の場合、その理由と措置を記入する
					●判定基準
					漁獲場所、むき身の量、生産者の名前または記録番号を記載するタグを確認する"
				guidelines_two = "●判定基準（続き）
					官能検査：見た目で異常がなく、異臭等が無いこと。
					品温：０～20℃
					ｐH：6.0～8.0
					塩分：0.5％以上
					最終判定：上記項目およびその他に異常がなく、原料として受け入れられるもの。"
				table_data << [{:content => "", :colspan => 10, :padding => 3}]
				table_data << [{:content => guidelines_one, :colspan => 5, :padding => 5, :size => 8}, {:content => guidelines_two, :colspan => 5, :padding => 5, :size => 8}]
				table_data << [{:content => "", :colspan => 10, :padding => 8}]
				table_data << [funabiki_info, logo_cell, created_info]
				pdf.table(table_data, :position => :center, :cell_style => { :inline_format => true, :border_width => 0 }, :width => pdf.bounds.width, :column_widths => {0..9 => (pdf.bounds.width / 10)} ) do |t|
					t.row(3).size = 12
					t.rows(3..4).font_style = :bold
					t.rows(0..2).columns(0..-1).border_width = 0.25
					t.row(-3).border_width = 0.25
					t.rows(4..5).border_width = 0.25
					t.rows(6..((@sakoshi_suppliers.length + @aioi_suppliers.length)* 2) + 5).columns(-1).border_right_width = 0.25
					t.row(((@sakoshi_suppliers.length + @aioi_suppliers.length)* 2) + 5).border_bottom_width = 0.25
					t.cells.rows(5..((@sakoshi_suppliers.length + @aioi_suppliers.length)* 2) + 5).columns(0..8).style do |c|
						( ((c.row % 2).zero?) && (c.column != 1) && (c.column != 2) ) ? (c.border_width = 0.25) : ()
						( (!(c.row % 2).zero?) && (c.column == 1) ) ? (c.border_right_width = 0.25 && c.border_bottom_width = 0.25) : ()
						( ((c.row % 2).zero?) && (c.column == 2) ) ? (c.border_left_width = 0.25) : ()
						( (!(c.row % 2).zero?) && (c.column == 2) ) ? (c.border_bottom_width = 0.25) : ()
						(c.column == 8) ? c.border_right_width = 0.25 : ()
						if c.background_color == darker
							t.rows(c.row).columns(2..8).background_color = darker
						end
					end
					t.row(5 + (@sakoshi_suppliers.length * 2)).column(-1).border_bottom_width = 0.25
				end
			end
			funabiki_logo.close
			return pdf
		end
	end

	def self.oyster_invoice(start_date, end_date, location, export_format, password = nil)
		require "prawn"
		require "open-uri"

		def self.weekday_japanese(num)
			#d.strftime("%w") to Japanese
			weekdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
			weekdays[num]
		end

		def self.type_to_japanese(type)
			japanese = {"large" => "むき身（大）", "small" => "むき身（小）", "eggy" => "むき身（卵）", "large_shells" => "殻付き（大）", "small_shells" => "殻付き（小）", "thin_shells" => "殻付き（バラ）"}
			japanese[type]
		end

		def self.type_to_unit(type)
			japanese = {"large" => "kg", "small" => "kg", "eggy" => "kg", "large_shells" => "個", "small_shells" => "個", "thin_shells" => "kg"}
			japanese[type]
		end

		def self.yenify(number)
			ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "")
		end

		def self.yenify_with_decimal(number)
			ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "", precision: 1)
		end

		# Set up varibles
		set_supply_variables
		date_range = Date.parse(start_date)..Date.parse(end_date) - 1.day
		funabiki_info = {:content => "<b>〒678-0232 </b>
		兵庫県赤穂市1576－11
		(株)船曳商店
		TEL (0791)43-6556 FAX (0791)43-8151
		メール info@funabiki.info", :size => 8}
		if location == "sakoshi"
			# Sakoshi Information
			info = {:content => "<b>〒678-0215 </b>
			兵庫県赤穂市御崎1798－1
			赤穂市漁業協同組合
			TEL 0791(45)2260 FAX 0791(45)2261", :size => 8}
			locale = "坂越"
			suppliers = @sakoshi_suppliers
		elsif location == "aioi"
			info = {:content => "<b>〒678-0041 </b>
			兵庫県相生市相生３丁目４−２２
			相生漁業協同組合
			TEL  0791(22)0344", :size => 8}
			locale = "相生"
		else
			info = ""
			locale = ""
		end

		# Widdle down the suppliers to only one's for the dates given
		supplier_ids = Set.new
		supplier_dates = Hash.new
		supplies_dates = Array.new
		date_range.each do |d|
			date = d.strftime('%Y年%m月%d日')
			oyster_supply = OysterSupply.find_by(supply_date: date)
			if !oyster_supply.nil?
				supplies_dates << oyster_supply.supply_date
				oysters = oyster_supply.oysters.except(:year_to_date, :updated)
				oysters.each do |time, type|
					if type.is_a?(Hash)
						type.each do |key, values|
							values.each do |id, v|
								if !v["subtotal"].nil?
									if (v["subtotal"] != "0")
										supplier_ids << id.to_i
										supplier_dates[id.to_i].nil? ? supplier_dates[id.to_i] = Set.new : ()
										supplier_dates[id.to_i] << date
									end
								elsif !v["0"].nil?
									if (v["0"] != "0")
										supplier_ids << id.to_i
										supplier_dates[id.to_i].nil? ? supplier_dates[id.to_i] = Set.new : ()
										supplier_dates[id.to_i] << date
									end
								end
							end
						end
					end
				end
			end
		end
		dates_for_print = "（" + supplies_dates.first + " ~ " + supplies_dates.last + "）"
		suppliers = Supplier.where(:id => supplier_ids).where(location: locale).order(:supplier_number)

		# Funabiki Logo
		funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")

		# TOTAL FARMERS OUTPUT
		if export_format == "all"
			Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [25], disposition: "inline") do |pdf|
				# document set up
				pdf.font_families.update(PrawnPDF.fonts)
				# set utf-8 japanese font
				pdf.font "MPLUS1p"
				pdf.font_size 10
				# Set up the table data and header
				table_data = Array.new
				table_data << [info, {:image => funabiki_logo, :scale => 0.065, :position  => :center }, funabiki_info]
				# Title rows
				table_data << [{:content => "<b>（" + locale + "）支払明細書</b>", :colspan => 3, :align => :center, :height => 35, :padding => 0}]
				table_data << [{:content => dates_for_print, :colspan => 3, :size => 8, :padding => 4, :align => :center}]
				table_data << [{:content => "", :colspan => 3, :size => 8, :padding => 2, :align => :center}]
				# Set up daily calculation header
				daily_tables = Array.new
				daily_tables << ["月日", "商品名", "数量", "単位", "単価", "金額", "総合計"]
				daily_tables_header = pdf.make_table(daily_tables, :width => 545, :cell_style => { :border_width => 0 }, :column_widths => {0 => 45, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 110}) do |t|
					t.row(0..-1).size = 9
				end
				# Daily calculations for matching records in the given date range go here
				i = 0
				total_no_tax = 0
				total_tax = 0
				volume_totals = Hash.new
				date_range.each do |d|
					date = d.strftime('%Y年%m月%d日')
					oyster_supply = OysterSupply.find_by(supply_date: date)
					if !oyster_supply.nil?
						data = oyster_supply.oyster_data
						if data[locale][:total] != 0
							total_no_tax += data[locale][:total]
							total_tax += data[locale][:tax]
							daily_data = Array.new
							# Just do the header once
							if i == 0
								daily_data << [{:content => daily_tables_header, :colspan => 7}]
								i += 1
							end
							daily_data_row = Array.new
							#daily_volume_row = Array.new
							# Make subtotal table
								subtotal_table_data = Array.new
								volume_subtotal_table_data = Array.new
								is = 0
								@types.each do |type|
									it = 0
									data[locale][type].each do |price, volume|
										if volume != 0
											subtotal_row = Array.new
											if is == 0
												subtotal_row << d.strftime('%m') + "." + d.strftime('%d') + "(" + weekday_japanese(d.strftime("%w").to_i) + ")"
												is += 1
											else
												subtotal_row << '　'
											end
											subtotal_row << type_to_japanese(type)
											subtotal_row << volume
											subtotal_row << type_to_unit(type)
											subtotal_row << yenify(price)
											subtotal_row << yenify((volume * price.to_f))
											subtotal_row << ""
											subtotal_table_data << subtotal_row
											if it == 0
												volume_subtotal_table_data << ["", {:content => ("―" + type_to_japanese(type) + "小計―"), :align => :right }, { :content => data[locale][:volume_total][type].to_s, :align => :right }, type_to_unit(type), "", yenify(data[locale][:price_type_total][type]), "" ]
												it += 1
											end
										end
									end
									volume_totals[type].nil? ? (volume_totals[type] = Hash.new) : ()
									volume_totals[type][:volume].nil? ? (volume_totals[type][:volume] = data[locale][:volume_total][type]) : (volume_totals[type][:volume] += data[locale][:volume_total][type])
									volume_totals[type][:total].nil? ? (volume_totals[type][:total] = data[locale][:price_type_total][type]) : (volume_totals[type][:total] += data[locale][:price_type_total][type])
								end
								subtotal_table_data << ["", "", "", "", "", { :content => "消費税(8%)", :align => :right }, "" ]
								subtotal_table = pdf.make_table(subtotal_table_data, :position => :center, :width => 544, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 45, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
									t.row(-1).column(-1).content = yenify(data[locale][:tax].to_f)
									t.row(-2).column(-1).content = yenify(data[locale][:total].to_f).to_s
									t.row(-1).column(-1).font_style = :light
									t.row(-2).column(-1).font_style = :bold
									values = t.cells.columns(0..-1).rows(0..-1)
									bad_cells = values.filter do |cell|
										cell.content == "0"
									end
									bad_cells.background_color = "FFAAAA"
								end
								#volume_subtotal_table = pdf.make_table(volume_subtotal_table_data, :position => :center, :width => 544, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
								#
								#end
							daily_data_row << { :content => subtotal_table, :colspan => 7 }
							#daily_volume_row << { :content => volume_subtotal_table, :colspan => 7, :height => 100 }
							daily_data << daily_data_row
							#daily_data << daily_volume_row
							volume_subtotal_table_data.each do |volume_data_row|
								daily_data << volume_data_row
							end
							daily_table = pdf.make_table(daily_data, :position => :center, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 110}) do |t|
								t.row(0).border_top_width = 0.5
								t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]

							end
							table_data << [{:content => daily_table, :colspan => 3}]
						end
					end
				end

				# Volume totals row
				volume_total_table_rows = Array.new
				volume_totals.each do |type, keys|
					if keys[:volume] != 0
						volume_total_table_rows << ["", { :content => ("―" + type_to_japanese(type) + "合計―"), :align => :right}, { :content => keys[:volume].to_s, :align => :right }, type_to_unit(type), "", { :content => yenify(keys[:total]) }, ""]
					end
				end
				if volume_total_table_rows.empty?
					volume_total_table_rows << [{ :content => ("単価は入力されていないです。もう一回確認は必要です。"), :align => :center, :colspan => 7}]
				end
				volume_total_table = pdf.make_table(volume_total_table_rows, :position => :center, :cell_style => { :inline_format => true, :size => 7, :border_width => 0, :padding => 3}, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
					t.row(0).border_top_width = 0.5
					t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]
				end
				# Total row
				total_table_rows = Array.new
				total_table_rows << ["買上金額", "消費税額", "今回支払金額"]
				total_table_rows << [ yenify(total_no_tax), yenify(total_tax), yenify(total_no_tax + total_tax)]
				total_table = pdf.make_table(total_table_rows, :position => :center, :cell_style => { :inline_format => true, :size => 8, :border_width => 0, :align => :center }) do |t|
					t.row(0).font_style = :bold
					t.row(0).border_bottom_width = 1
					t.row(0).border_bottom_width = 1
					t.row(0).border_top_width = 1
					t.row(-1).border_bottom_width = 1
					t.column(0).border_left_width = 1
					t.column(-1).border_right_width = 1
				end
				table_data << [{:content => " ", :colspan => 3, :height => 7}]
				table_data << [{:content => volume_total_table, :colspan => 3}]
				table_data << [{:content => " ", :colspan => 3, :height => 7}]
				table_data << [{:content => total_table, :colspan => 3}]
				table_data << [{:content => " ", :colspan => 3, :height => 7}]

				pdf.table(table_data, :position => :center, :cell_style => { :inline_format => true, :min_font_size => 8 }, :width => 545.28, :column_widths => {0 => 181.76, 1 => 181.76, 2 => 181.76}) do |t|
					t.cells.border_width = 0
						t.row(0).padding = 5
						t.row(0).border_top_width = 2
						t.row(-1).border_bottom_width = 2
						t.column(0).border_left_width = 2
						t.column(-1).border_right_width = 2
						t.row(0).border_bottom_width = 0.15
						t.row(1).column(-1).size = 8
						t.row(1).column(0).size = 12
						t.row(1).padding = 10
						t.row(-3).border_lines = [:dotted, :solid, :solid, :solid]
						t.row(-3).border_top_width = 0.5
					t.before_rendering_page do |page|
						page.row(0).border_top_width = 2
						page.row(-1).border_bottom_width = 2
						page.column(0).border_left_width = 2
						page.column(-1).border_right_width = 2
					end
				end

				pdf.encrypt_document(user_password: password,owner_password: password) unless password.nil?
				pdf_data = pdf
				funabiki_logo.close
				return pdf_data
			end

		# INDIVIDUAL FARMER OUTPUT
		elsif export_format == "individual"
			#get the year to date totals ready
			last_date_record = OysterSupply.find_by(supply_date: supplies_dates.last)
			year_to_date_data = last_date_record.year_to_date
			# document set up
			Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [25]) do |pdf|
				# set utf-8 japanese font
				pdf.font_families.update(PrawnPDF.fonts)

				pdf.font "MPLUS1p"
				pdf.font_size 10

				suppliers.each_with_index do |supplier, i|
					if i != 0
						pdf.start_new_page
					end
					# Set up the table data and header
					table_data = Array.new
					table_data << [info, {:image => funabiki_logo, :scale => 0.065, :position  => :center }, funabiki_info]
					# Title rows
					table_data << [{:content => "<b>〔" + supplier.supplier_number.to_s + "〕 " + supplier.company_name + " ― 支払明細書</b>", :colspan => 3, :align => :center}]
					table_data << [{:content => "（" + supplies_dates.first + " ~ " + supplies_dates.last + "）", :colspan => 3, :size => 8, :padding => 4, :align => :center}]
					table_data << [{:content => "", :colspan => 3, :size => 8, :padding => 2, :align => :center}]
					# Set up daily calculation header
					daily_tables_h_row = Array.new
					daily_tables_h_row << ["月日", "商品名", "数量", "単位", "単価", "金額", "総合計"]
					daily_tables_header = pdf.make_table(daily_tables_h_row, :header => true, :width => 545, :cell_style => { :border_width => 0 }, :column_widths => {0 => 45, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 110}) do |t|
						t.row(0..-1).size = 9
					end

					i = 0
					total_no_tax = 0
					total_tax = 0
					supplier_total = 0
					supplier_type_totals = Hash.new
					supplier_dates[supplier.id].each do |date|
						day_total = 0
						oyster_supply = OysterSupply.find_by(supply_date: date)
						if !oyster_supply.nil?
							data = oyster_supply.oysters
							d = Date.strptime(date, "%Y年%m月%d日")
							gapi = d.strftime('%m').to_s + "." + d.strftime('%d').to_s + "(" + weekday_japanese(d.strftime("%w").to_i).to_s + ")"
							daily_data = Array.new
							# Just do the header once
							if i == 0
								daily_data << [{:content => daily_tables_header, :colspan => 7}]
								i += 1
							end
							it = 0
							@types.each do |type|
								volume = data[type][supplier.id.to_s]["volume"]
								price = data[type][supplier.id.to_s]["price"]
								subtotal = yenify((volume.to_f * price.to_f))
								if volume != "0"
									if it == 0
										daily_data << [gapi, type_to_japanese(type), volume, type_to_unit(type), yenify(price), subtotal, "" ]
										it += 1
									else
										daily_data << ["", type_to_japanese(type), volume, type_to_unit(type), yenify(price), subtotal, "" ]
									end
								end
								day_total += (volume.to_f * price.to_f)
								total_no_tax += (volume.to_f * price.to_f)
								total_tax += ((volume.to_f * price.to_f) * 0.08)
								supplier_total += (volume.to_f * price.to_f)
								supplier_type_totals[type].nil? ? supplier_type_totals[type] = Hash.new : ()
								supplier_type_totals[type][:volume].nil? ? supplier_type_totals[type][:volume] = volume.to_f : supplier_type_totals[type][:volume] += volume.to_f
								supplier_type_totals[type][:total].nil? ? supplier_type_totals[type][:total] = (volume.to_f * price.to_f) : supplier_type_totals[type][:total] += (volume.to_f * price.to_f)
							end
							daily_data << ["", "", "", "", "", { :content => "消費税(8%)", :align => :right }, "" ]
							daily_table = pdf.make_table(daily_data, :position => :center, :width => 545, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 50, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 105}) do |t|
								t.row(0).border_top_width = 0.5
								t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]
								t.rows(0..-1).size = 8
								t.row(-1).column(-1).content = yenify(day_total)
								t.row(-1).column(-1).font_style = :bold
								t.row(-2).column(-1).content = yenify(day_total)
								t.row(-2).column(-1).font_style = :bold
								t.row(-1).column(-1).content = yenify_with_decimal(day_total * 0.08)
								t.row(-1).column(-1).font_style = :light
								values = t.cells.columns(0..-1).rows(0..-1)
								bad_cells = values.filter do |cell|
									cell.content == "0"
								end
								bad_cells.background_color = "FFAAAA"
							end
							table_data << [{:content => daily_table, :colspan => 3}]
						end
					end

					# Volume totals row
					volume_total_table_rows = Array.new
					supplier_type_totals.each do |type, keys|
						if keys[:volume] != 0
							volume_total_table_rows << ["", { :content => ("―" + type_to_japanese(type) + "合計―"), :align => :right}, { :content => keys[:volume].to_s, :align => :right }, type_to_unit(type), "", { :content => yenify(keys[:total].to_s) }, ""]
						end
					end
					volume_total_table = pdf.make_table(volume_total_table_rows, :position => :center, :cell_style => { :inline_format => true, :size => 7, :border_width => 0, :padding => 3}, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
						t.row(0).border_top_width = 0.5
						t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]
					end

					# Total row
					total_table_rows = Array.new
					total_table_rows << ["買上金額", "消費税額", "今回支払金額"]
					total_table_rows << [ yenify(total_no_tax), yenify(total_tax), yenify(total_no_tax + total_tax)]
					total_table = pdf.make_table(total_table_rows, :header => true, :position => :center, :cell_style => { :inline_format => true, :size => 8, :border_width => 0, :height => 18, :align => :center }) do |t|
						t.row(0).font_style = :bold
						t.row(0).border_bottom_width = 1
						t.row(0).border_bottom_width = 1
						t.row(0).border_top_width = 1
						t.row(-1).border_bottom_width = 1
						t.column(0).border_left_width = 1
						t.column(-1).border_right_width = 1
					end

					table_data << [{:content => " ", :colspan => 3, :height => 7}]
					table_data << [{:content => volume_total_table, :colspan => 3}]
					table_data << [{:content => " ", :colspan => 3, :height => 7}]
					table_data << [{:content => total_table, :colspan => 3}]
					table_data << [{:content => " ", :colspan => 3, :height => 7}]

					pdf.table(table_data, :position => :center, :header => true, :cell_style => { :inline_format => true, :min_font_size => 8 }, :width => 545.28, :column_widths => {0 => 181.76, 1 => 181.76, 2 => 181.76}) do |t|
						t.cells.border_width = 0
						t.before_rendering_page do |page|
							page.row(0).padding = 5
							page.row(0).border_top_width = 2
							page.row(-1).border_bottom_width = 2
							page.column(0).border_left_width = 2
							page.column(-1).border_right_width = 2
							page.row(0).border_bottom_width = 0.15
							page.row(1).column(-1).size = 8
							page.row(1).column(0).size = 12
							page.row(1).padding = 10
							page.row(1).height = 50
							t.row(-3).border_lines = [:dotted, :solid, :solid, :solid]
							t.row(-3).border_top_width = 0.5
						end
					end

					# Year to date calculations by supplier
					pdf.move_down 10
					yearly = year_to_date_data[supplier.id.to_s]
					yearly_data = Array.new
					yearly_data << [{:content => "今シーズンの総合計算", :colspan => (@types.size + 1)}]
					type_row = Array.new
					price_row = Array.new
					invoice_row = Array.new
					volume_row = Array.new
					@types.each_with_index do |type, i|
						if i == 0
							type_row << " "
							price_row << "平均単価"
							invoice_row << "合計金額"
							volume_row << "計量合計"
						end
						price_average = (yearly[type][:price].inject{ |sum, el| sum + el }.to_f / yearly[type][:price].size)
						price_average.nan? ? price_average = "0" : price_average
						type_row << type_to_japanese(type)
						price_row << yenify(price_average.to_f.round(0))
						invoice_row << yenify(yearly[type][:invoice])
						volume_row << yearly[type][:volume].to_s
					end
					yearly_data << type_row
					yearly_data << volume_row
					yearly_data << price_row
					yearly_data << invoice_row
					pdf.table(yearly_data, :position => :center, :width => 545.28, :cell_style => { :inline_format => true, :size => 7, :align => :center, :border_width => 0.25 }) do |t|
						t.row(0).size = 10
						t.row(0).font_style =:bold
						t.row(0).border_top_width = 1
						t.row(-1).border_bottom_width = 1
						t.column(0).border_left_width = 1
						t.column(-1).border_right_width = 1
					end

				end

				pdf.encrypt_document(user_password: password,owner_password: password) unless password.nil?
				pdf_data = pdf
				funabiki_logo.close
				return pdf_data
			end
		else
			#do nothing, unexpected param is bad.
		end
	end

end
