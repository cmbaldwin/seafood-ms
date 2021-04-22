class OnlineOrder < ApplicationRecord

	validates_presence_of :order_id
	validates_uniqueness_of :order_id

	serialize :data

	def cancelled
		self.status == "cancelled"
	end

	def url
		"https://funabiki.info/wp-admin/post.php?post=#{self.order_id}&action=edit"
	end

	def item_count(product_id)
		# %w{生むき身 生セル 小殻付 セルカード 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(100g) 干し殻付エビ(100g) タコ}
		shells = {
			437 => [0, 10, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			516 => [0, 20, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			517 => [0, 30, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			519 => [0, 40, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			520 => [0, 50, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			521 => [0, 60, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			838 => [0, 70, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			522 => [0, 80, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			837 => [0, 90, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			523 => [0, 100, 0, 1, 0, 0, 0, 0, 0, 0, 0] }
		small_shells = {
			13867 => [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
			13883 => [0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0],
			13884 => [0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0],
			13885 => [0, 0, 5, 1, 0, 0, 0, 0, 0, 0, 0], }
		mukimi = {
			583 => [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			581 => [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			580 => [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			579 => [4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			578 => [5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			577 => [6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6555 => [7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6556 => [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6557 => [9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6558 => [10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6559 => [11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6560 => [12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
		sets = {
			584 => [1, 10, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			590 => [1, 20, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			591 => [1, 30, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			592 => [2, 20, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			593 => [2, 30, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			594 => [2, 40, 0, 1, 0, 0, 0, 0, 0, 0, 0] }
		dekapuri = {
			524 => [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
			645 => [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0],
			646 => [0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0],
			6554 => [0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0],
			13551 => [0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0],
			13552 => [0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0] }
		rshells = {
			13585 => [0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0],
			13584 => [0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0],
			13583 => [0, 0, 0, 0, 0, 30, 0, 0, 0, 0, 0],
			13582 => [0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0],
			13580 => [0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0],
			13579 => [0, 0, 0, 0, 0, 60, 0, 0, 0, 0, 0],
			13577 => [0, 0, 0, 0, 0, 70, 0, 0, 0, 0, 0],
			13586 => [0, 0, 0, 0, 0, 80, 0, 0, 0, 0, 0],
			13587 => [0, 0, 0, 0, 0, 90, 0, 0, 0, 0, 0],
			13588 => [0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0] }
		other = {
			596 => [0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
			595 => [0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0],
			598 => [0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0],
			599 => [0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0],
			600 => [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0],
			597 => [0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0],
			572 => [0, 0, 0, 0, 0, 0, 1, 400, 0, 0, 0],
			575 => [0, 0, 0, 0, 0, 0, 1, 550, 0, 0, 0],
			576 => [0, 0, 0, 0, 0, 0, 1, 700, 0, 0, 0],
			13641 => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			500 => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			6319 => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
		hashes = [shells, small_shells, mukimi, sets, dekapuri, rshells, other]
		all_items = hashes.inject(&:merge)
		all_items.key?(product_id) ? all_items[product_id] : [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	end

	def item_name(item_id)
		shells = {
			437 => "殻付き 牡蠣10ヶ",
			516 => "殻付き 牡蠣20ヶ",
			517 => "殻付き 牡蠣30ヶ",
			519 => "殻付き 牡蠣40ヶ",
			520 => "殻付き 牡蠣50ヶ",
			521 => "殻付き 牡蠣60ヶ",
			838 => "殻付き 牡蠣70ヶ",
			522 => "殻付き 牡蠣80ヶ",
			837 => "殻付き 牡蠣90ヶ",
			523 => "殻付き 牡蠣100ヶ" }
		small_shells = {
			13867 => "小殻付き 1㎏",
			13883 => "小殻付き 2㎏",
			13884 => "小殻付き 3㎏",
			13885 => "小殻付き 5㎏", }
		mukimi = {
			583 => "生牡蠣むき身500g×1",
			581 => "生牡蠣むき身500g×2",
			580 => "生牡蠣むき身500g×3",
			579 => "生牡蠣むき身500g×4",
			578 => "生牡蠣むき身500g×5",
			577 => "生牡蠣むき身500g×6",
			6555 => "生牡蠣むき身500g×7",
			6556 => "生牡蠣むき身500g×8",
			6557 => "生牡蠣むき身500g×9",
			6558 => "生牡蠣むき身500g×10",
			6559 => "生牡蠣むき身500g×11",
			6560 => "生牡蠣むき身500g×12" }
		sets = {
			584 => "むき身500g×1 + 殻付10個",
			590 => "むき身500g×1 + 殻付20個",
			591 => "むき身500g×1 + 殻付30個",
			592 => "むき身500g×2 + 殻付20個",
			593 => "むき身500g×2 + 殻付30個",
			594 => "むき身500g×2 + 殻付40個" }
		dekapuri = {
			524 => "冷凍 牡蠣むき身500g×1",
			645 => "冷凍 牡蠣むき身500g×2",
			646 => "冷凍 牡蠣むき身500g×3",
			6554 => "冷凍 牡蠣むき身500g×4",
			13551 => "冷凍 牡蠣むき身500g×10",
			13552 => "冷凍 牡蠣むき身500g×20" }
		rshells = {
			13585 => "冷凍 殻付き 牡蠣10ヶ",
			13584 => "冷凍 殻付き 牡蠣20ヶ",
			13583 => "冷凍 殻付き 牡蠣30ヶ",
			13582 => "冷凍 殻付き 牡蠣40ヶ",
			13580 => "冷凍 殻付き 牡蠣50ヶ",
			13579 => "冷凍 殻付き 牡蠣60ヶ",
			13577 => "冷凍 殻付き 牡蠣70ヶ",
			13586 => "冷凍 殻付き 牡蠣80ヶ",
			13587 => "冷凍 殻付き 牡蠣90ヶ",
			13588 => "冷凍 殻付き 牡蠣100ヶ" }
		other = {
			596 => "干えび(ムキ) 100g×3袋",
			595 => "干えび(ムキ) 100g×5袋",
			598 => "干えび(殻付)100g×10袋",
			599 => "干えび(殻付)100g×3袋",
			600 => "干えび(殻付)100g×5袋",
			597 => "干えび(ムキ) 100g×2袋 + (殻付) 100g×2袋",
			13641 => "ボイルたこ (800g~1k)",
			572 => "焼穴子 400g入",
			575 => "焼穴子 550g入",
			576 => "焼穴子 700g入",
			500 => "牡蠣ナイフ",
			6319 => "熨斗" }
		hashes = [shells, small_shells, mukimi, sets, dekapuri, rshells, other]
		all_items = hashes.inject(&:merge)
		all_items.key?(item_id) ? all_items[item_id] : "???"
	end

	def is_frozen?(product_id)
		!item_count(product_id)[4..5].sum.zero?
	end

	def is_raw?(product_id)
		!(item_count(product_id)[0..2] + item_count(product_id)[6..10]).sum.zero?
	end

	def print_item_array
		print_items = {:raw => [], :frozen => []}
		self.items.each do |item|
			product_id = item["product_id"]
			unless is_frozen?(product_id)
				def is_set?(count)
					!count[0].zero? && !count[1].zero?
				end
				def is_other?(count)
					!count[2..-1].sum.zero?
				end
				count = item_count(product_id)
				count.delete_at(3) #remove shell cards count
				# 0生むき身 1生セル 2小殻付 3冷凍むき身 4冷凍セル 5穴子(件) 6穴子(g) 7干しムキエビ(100g) 8干し殻付エビ(100g) 9タコ
				quantity = item["quantity"]
				# ['#', '注文者', '届先', '500g', 'セル', 'セット', その他', 'お届け日', '時間', '備考']
				# skip #, added via unshift on pdf creation
				print_items[:raw] << [ 
					sender_name,
					(unique_recipient ? recipient_name : '""'),
					(is_set?(count) ? '' : (count[0].zero? ? '' : "#{'(' if (quantity > 1)}#{count[0]}p#{(') x' + quantity) if (quantity > 1)}")),
					(is_set?(count) ? '' : (count[1].zero? ? '' : "#{'(' if (quantity > 1)}#{count[1]}p#{(') x' + quantity) if (quantity > 1)}")),
					(is_set?(count) ? "#{'(' if (quantity > 1)}500g#{count[0]} + #{count[1]}個#{(') x' + quantity) if (quantity > 1)}" : ''),
					(is_other?(count) ? "#{'(' if (quantity > 1)}#{item_name(product_id)}#{(') x' + quantity) if (quantity > 1)}" : ''),
					self.arrival_date.to_s,
					(arrival_time.nil? ? '' : arrival_time),
					"#{'代引き' if payment_method == "cod"}"
				]
			else
				# skip #, added via unshift on pdf creation				
				count = item_count(product_id)
				count.delete_at(3) #remove shell cards count
				# 0生むき身 1生セル 2小殻付 3冷凍むき身 4冷凍セル 5穴子(件) 6穴子(g) 7干しムキエビ(100g) 8干し殻付エビ(100g) 9タコ
				quantity = item["quantity"]
				# ['#', '注文者', '届先', '冷凍 500g', '冷凍 セル', お届け日', '時間', '備考']
				# skip #, added via unshift on pdf creation
				print_items[:frozen] << [ sender_name,
					(unique_recipient ? recipient_name : '""'),
					(count[3].zero? ? '' : "#{'(' if (quantity > 1)}#{count[3]}p#{(') x' + quantity) if (quantity > 1)}"),
					(count[4].zero? ? '' : "#{'(' if (quantity > 1)}#{count[4]}個#{(') x' + quantity) if (quantity > 1)}"),
					self.arrival_date.to_s,
					(arrival_time.nil? ? '' : arrival_time),
					"#{'代引き' if payment_method == "cod"}"
				]
			end
		end
		print_items
	end

	def payment_method
		self.data["payment_method"]
	end

	def knife
		if item_id_array.include?(500)
			quantity = (items.map{|item| item["quantity"] if item["id"] == 500 }.first)
			quantity.nil? ? 1 : 1 * quantity
		else 
			0
		end
	end

	def noshi
		if item_id_array.include?(6319)
			quantity = (items.map{|item| item["quantity"] if item["id"] == 6319 }.first)
			quantity.nil? ? 1 : 1 * quantity
		else 
			0
		end
	end

	def items
		self.data["line_items"]
	end

	def item_id_array
		items.map{ |item| item["product_id"] }
	end

	def counts
		self.item_id_array.inject([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]){ |memo, item_id| self.item_count(item_id).each_with_index{ |c, i| memo[i] += c }; memo }
	end

	def sender
		self.data["billing"]
	end

	def sender_name
		self.sender["last_name"] + self.sender["first_name"]
	end

	def get_meta(key)
		self.data["meta_data"].map{|meta_hash| meta_hash["value"] if meta_hash["key"] == key }.compact.first
	end

	def arrival_time
		get_meta("wc4jp-delivery-time-zone")
	end

	def recipient
		self.data["shipping"]
	end

	def recipient_name
		self.recipient["last_name"] + self.recipient["first_name"]
	end

	def unique_recipient
		(sender["address_1"] != recipient["address_1"]) || (sender_name != recipient_name)
	end

	def status_jp
		{
			"processing" => "処理中",
			"cancelled" => "キャンセル",
			"on-hold" => "保留中",
			"completed" => "完了",
		}[status]
	end

end
