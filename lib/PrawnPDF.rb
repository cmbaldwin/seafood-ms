class PrawnPDF
	require 'prawn-rails'

	def self.yahoo_shipping_pdf(ship_date)
		orders = YahooOrder.where(ship_date: ship_date)

		def self.order_counts(orders)
			counts = Hash.new
			types_arr = %w{生むき身 生セル 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(80g) 干し殻付エビ(80g) タコ}
			types_arr.each {|w| counts[w] = 0}
			count_hash = { 
				"kakiset302" => [2, 30, 0, 0, 0, 0, 0, 0, 0],
				"kakiset202" => [2, 20, 0, 0, 0, 0, 0, 0, 0],
				"kakiset301" => [1, 30, 0, 0, 0, 0, 0, 0, 0],
				"kakiset201" => [1, 20, 0, 0, 0, 0, 0, 0, 0],
				"kakiset101" => [1, 10, 0, 0, 0, 0, 0, 0, 0],
				"karatsuki100" => [0, 100, 0, 0, 0, 0, 0, 0, 0],
				"karatsuki50" => [0, 50, 0, 0, 0, 0, 0, 0, 0],
				"karatsuki40" => [0, 40, 0, 0, 0, 0, 0, 0, 0],
				"karatsuki30" => [0, 30, 0, 0, 0, 0, 0, 0, 0],
				"karatsuki20" => [0, 20, 0, 0, 0, 0, 0, 0, 0],
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
				"mebi80x5" => [0, 0, 0, 0, 0, 0, 5, 0, 0],
				"mebi80x3" => [0, 0, 0, 0, 0, 0, 3, 0, 0],
				"hebi80x10" => [0, 0, 0, 0, 0, 0, 0, 10, 0],
				"hebi80x5" => [0, 0, 0, 0, 0, 0, 0, 5, 0],
				"anago600" => [0, 0, 0, 0, 1, 600, 0, 0, 0],
				"anago480" => [0, 0, 0, 0, 1, 480, 0, 0, 0],
				"anago350" => [0, 0, 0, 0, 1, 350, 0, 0, 0] }
			orders.each do |order|
				count_hash[order.item_id].each_with_index do |count, i|
					counts[types_arr[i]] += count
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
				"mukimi04" => ["500g×4", "", "", ""],
				"mukimi03" => ["500g×3", "", "", ""],
				"mukimi02" => ["500g×2", "", "", ""],
				"mukimi01" => ["500g×1", "", "", ""],
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

		pdf = Prawn::Document.new(margin: [15])
		pdf.font_families.update("SourceHan" => {
			:normal => ".fonts/SourceHan/SourceHanSans-Normal.ttf",
			:bold => ".fonts/SourceHan/SourceHanSans-Bold.ttf",
			:light => ".fonts/SourceHan/SourceHanSans-Light.ttf",
		})
		#set utf-8 japanese font
		pdf.font_size 16
		pdf.font "SourceHan", :style => :bold
		pdf.text ship_date + "  ヤフーショッピング 発送表"
		pdf.font "SourceHan", :style => :normal
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
			order_arr << item[0]
			order_arr << item[1]
			order_arr << item[2]
			order_arr << item[3]
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

		pdf.render
	end

end