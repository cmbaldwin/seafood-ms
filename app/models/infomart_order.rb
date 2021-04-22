class InfomartOrder < ApplicationRecord

	validates_presence_of :order_id
	validates_uniqueness_of :order_id

	serialize :items
	serialize :csv_data

	def attribute_sym_to_ja(attribute)
		{
			:order_id => "伝票No",
			:order_time => "送信日時",
			:ship_date => "発送日",
			:arrival_date => "納品日",
			:item_id => "マイカタログID",
			:item_code => "自社管理商品コード",
			:name => "商品名",
			:standard => "規格",
			:in_box_quantity => "入数",
			:in_box_counter => "入数単位",
			:price => "単価",
			:quantity => "数量",
			:counter => "単位",
			:item_subtotal => "消費税",
			:tax => "小計",
			:subtotal => "課税区分",
			:tax_rate => "税区分",
			:tax_category => "税区分",
			:all_item_total => "合計 商品本体",
			:all_item_tax => "合計 商品消費税",
			:all_item_shipping => "合計 送料本体",
			:all_item_shipping_tax => "合計 送料消費税",
			:other_total => "合計 その他",
			:order_total => "総合計",
			:transaction_id => "取引ID",
			:address => "納品場所 住所"
		}[attribute]
	end

	def backend_id
		"1" + self.items["1"][:transaction_id]
	end

	def cancelled
		self.status == "ｷｬﾝｾﾙ(取引)"
	end

	def arrival_gapi
		self.arrival_date.strftime("%m月%d日")
	end

	def short_destination
		self.destination[/.*(?=\（)/]
	end

	def item_array
		items = {:raw => [], :frozen => []}
		self.items.each do |item_number, item|
			if item[:item_code]
				count = [0, 0, 0, 0, 0, 0, 0, 0]
				codified_item = codify_item(item)
				add_item_too_count(item, count)
				# ['#', '飲食店', '届け先', '500g', '1kg', 'セル', 'その他', 'お届け日', '時間', '備考']
				if codified_item[0] == "n"
					items[:raw] << [short_destination, '""',
						count[0].zero? ? '' : "#{count[0]}p", 
						count[1].zero? ? '' : "#{count[1]}枚", 
						count[2].zero? ? '' : "#{count[2]}個", 
						" ", 
						arrival_gapi, 
						"午前　14-16", 
						" "]
				end
				# ['#', '飲食店', '届け先', '500g (L)', '500g (LL)', '500g (生)', 'セル', '小セル', 'お届け日', '時間', '備考']
				if codified_item[0] == "r"
					items[:frozen] << [short_destination, '""',
						count[3].zero? ? '' : "#{count[3]}p", 
						count[4].zero? ? '' : "#{count[4]}p", 
						count[5].zero? ? '' : "#{count[5]}p", 
						count[6].zero? ? '' : "#{count[6]}箱", 
						count[7].zero? ? '' : "#{count[7]}個", 
						arrival_gapi, 
						"午前　14-16", 
						" "]
				end
			end
		end
		items
	end

	def codify_item(item)
		codified_item = []
		item[:item_code].scan(/([a-z]{1,2}(?=-))/){|code| codified_item << code }
		codified_item.flatten!
	end

	def add_item_too_count(item, count)
		#      0         1         2         3       4        5         6         7
		# [ nama_500, nama_1k, nama_shell, frz_l, frz_ll, frz_nama, frz_shell, jp_shell ]
		codified_item = codify_item(item)
		unless codified_item.nil?
			item[:in_box_quantity].to_i.zero? ? in_box = 1 : in_box = item[:in_box_quantity].to_i
			quantity = item[:quantity].to_i * in_box if ((codified_item[0] == "r") || (codified_item[0] == "n"))
			if codified_item[0] == "r" #Frozen
				if codified_item[1] == "sh" #Shells
					if codified_item[3] == "lg" #Normal
						count[6] += quantity
					elsif codified_item[3] == "xl" #XLarge
						count[6] += quantity
					elsif codified_item[3] == "sm" #Small
						count[7] += quantity
					end
				elsif codified_item[1] == "dp"
					if codified_item[2] == "s"
						if codified_item[3] == "lg"
							if self.destination.include?('ＷＤＩ')
								count[5] += quantity
							else
								count[3] += quantity
							end
						else #LL
							count[4] += quantity
						end
					else #Okayama
						count[5] += 1
					end
				end
			elsif codified_item[0] == "n"
				if codified_item[1] == "sh"
					count[2] += quantity
				elsif codified_item[1] == "mk"
					count[0] += quantity
				end
			end
		else
			"Error with item, logging item data:"
			ap item
		end
	end

	def counts
		count = [0, 0, 0, 0, 0, 0, 0, 0]
		self.items.each do |item_number, item|
			if item[:item_code]
				add_item_too_count(item, count)
			end
		end
		count
	end

end
