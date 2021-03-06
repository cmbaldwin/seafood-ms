class YahooOrder < ApplicationRecord

	validates_presence_of :order_id
	validates_uniqueness_of :order_id

	serialize :details, Hash

	def order_time
		DateTime.parse(self.details["OrderTime"])
	end

	def order_status(for_print = true)
		status = self.details["OrderStatus"]
		unless self.ship_date == nil
			print_status = {1 => '予約中', 2 => '処理中', 3 => '保留', 4 => 'キャンセル', 5 => '完了'}
			for_print ? print_status[status.to_i] : status.to_i
		else
			for_print ? '新規' : status.to_i
		end
	end

	def shipping_status(for_print = true)
		if self.details["Ship"]
			status = self.details["Ship"]["ShipStatus"]
			print_status = { 1 => "決済申込", 2 => "支払待ち", 3 => "支払完了", 4 => "入金待ち", 5 => "決済完了", 6 => "キャンセル", 7 => "返金", 8 => "有効期限切れ", 9 => "決済申込中", 10 => "オーソリエラー", 11 => "売上取消", 12 => "Suicaアドレスエラー"}
			for_print ? print_status[status.to_i] : status
		end
	end

	def url
		"https://pro.store.yahoo.co.jp/pro.oystersisters/order/manage/detail/" + self.order_id
	end

	def contact_url
		'https://pro.store.yahoo.co.jp/pro.oystersisters/order/manage/detail/mail_and_form/' + self.order_id
	end

	def yahoo_id
		self.details["OrderId"]
	end

	def billing_name
		self.details["Pay"]["BillLastName"] + " " + self.details["Pay"]["BillFirstName"] if self.details["Pay"]
	end

	def billing_name_kana
		self.details["Pay"]["BillLastNameKana"] + " " + self.details["Pay"]["BillFirstNameKana"]
	end

	def billing_phone
		if self.shipping_details["BillPhoneNumber"].nil?
			((self.billing_name == self.shipping_name) ? shipping_details["ShipPhoneNumber"] : "0791436556")
		else
			shipping_details["BillPhoneNumber"] 
		end
	end

	def item_options
		details = self.item_details
		if details.is_a?(Hash)
			[ details["ItemOption"] ]
		else #it's an array of hashes
			details.map{|i| i["ItemOption"] }
		end
	end

	def knife_count
		item_options.compact.flatten.map{|o| o["Name"].include?('ナイフ') ? (o["Value"].include?('あり') ? 1 : 0) : 0 }.sum
	end

	def shipping_name
		self.shipping_details["ShipLastName"] + " " + self.shipping_details["ShipFirstName"]
	end

	def shipping_name_kana
		self.shipping_details["ShipLastNameKana"] + " " + self.shipping_details["ShipFirstNameKana"]
	end

	def shipping_details
		self.details["Ship"]
	end

	def shipping_phone
		self.shipping_details["ShipPhoneNumber"]
	end

	def billing_details
		self.details["Pay"]
	end

	def item_details
		self.details["Item"]
	end

	def item_ids
		if self.item_details.is_a?(Hash)
			[self.item_details["ItemId"]]
		elsif self.item_details.is_a?(Array)
			self.item_details.map{|i| i["ItemId"]}
		end
	end

	def item_names
		item_names = { 
			"kakiset302" => "むき身500g×2 + 殻付30個",
			"kakiset202" => "むき身500g×2 + 殻付20個",
			"kakiset301" => "むき身500g×1 + 殻付30個",
			"kakiset201" => "むき身500g×1 + 殻付20個",
			"kakiset101" => "むき身500g×1 + 殻付10個",
			"karatsuki100" => "殻付き 牡蠣100ヶ",
			"karatsuki50" => "殻付き 牡蠣50ヶ",
			"karatsuki40" => "殻付き 牡蠣40ヶ",
			"karatsuki30" => "殻付き 牡蠣30ヶ",
			"karatsuki20" => "殻付き 牡蠣20ヶ",
			"karatsuki10" => "殻付き 牡蠣10ヶ",
			"mukimi04" => "生牡蠣むき身500g×4",
			"mukimi03" => "生牡蠣むき身500g×3",
			"mukimi02" => "生牡蠣むき身500g×2",
			"mukimi01" => "生牡蠣むき身500g×1",
			"pkara100" => "冷凍 殻付き 牡蠣100ヶ",
			"pkara50" => "冷凍 殻付き 牡蠣50ヶ",
			"pkara40" => "冷凍 殻付き 牡蠣40ヶ",
			"pkara30" => "冷凍 殻付き 牡蠣30ヶ",
			"pkara20" => "冷凍 殻付き 牡蠣20ヶ",
			"pkara10" => "冷凍 殻付き 牡蠣10ヶ",
			"pmuki04" => "冷凍 牡蠣むき身500g×4",
			"pmuki03" => "冷凍 牡蠣むき身500g×3",
			"pmuki02" => "冷凍 牡蠣むき身500g×2",
			"pmuki01" => "冷凍 牡蠣むき身500g×1",
			"tako1k" => "ボイルたこ 800g",
			"mebi80x5" => "干えび(ムキ) 80g×5袋",
			"mebi80x3" => "干えび(ムキ) 80g×3袋",
			"hebi80x10" => "干えび(殻付) 80g×10袋",
			"hebi80x5" => "干えび(殻付) 80g×5袋 ",
			"anago600" => "焼穴子 600g入",
			"anago480" => "焼穴子 480g入",
			"anago350" => "焼穴子 350g入",
			"syoukara1kg" => "小殻付き 1㎏",
			"syoukara2kg" => "小殻付き 2㎏",
			"syoukara3kg" => "小殻付き 3㎏",
			"syoukara5kg" => "小殻付き 5㎏" }
		item_ids.map{|i| item_names[i]}
	end

	def payment_type
		pay_method = self.billing_details["PayMethod"]
		method_hash = {
			"payment_a1" => "クレジットカード決済",
			"payment_a17" => "PayPay残高払い",
			"payment_a6" =>"コンビニ (セブン-イレブン）",
			"payment_a7" => "コンビニ（ファミリーマート、ローソン、その他）",
			"payment_a8" => "モバイルSuica",
			"payment_a9" => "ドコモ ケータイ払い",
			"payment_a10" => "auかんたん決済",
			"payment_a11" => "ソフトバンクまとめて支払い",
			"payment_b1" => "銀行振込",
			"payment_d1" => "商品代引" }
		method_hash.include?(pay_method) ? method_hash[pay_method] : pay_method
	end

	def quantities
		if self.item_details.is_a?(Hash)
			self.item_details ? [self.item_details["Quantity"]] : ["0"]
		else
			self.item_details.map{|item| item["Quantity"] }
		end
	end

	def print_quantity(i)
		(self.quantities[i].to_i > 1) ? (" × " + self.quantities[i]) : ""
	end

	def shipping_address(for_print = false)
		address = {prefecture: self.shipping_details["ShipPrefecture"], city: self.shipping_details["ShipCity"], address1: self.shipping_details["ShipAddress1"], address2: self.shipping_details["ShipAddress2"], phone: self.shipping_details["ShipPhoneNumber"]}
		for_print ? (address.each {|k,v| (v + "\n") if !v.nil? }) : address
	end

	def billing_address(for_print = false)
		address = {prefecture: self.billing_details["BillPrefecture"], city: self.billing_details["BillCity"], address1: self.billing_details["BillAddress1"], address2: self.billing_details["BillAddress2"], phone: self.billing_details["BillPhoneNumber"]}
		for_print ? (address.each {|k,v| (v + "\n") if !v.nil? }) : address
	end

	def shipping_type
		#if it's collect set to 2
		self.billing_details["PayMethod"] == "payment_d1" ? "2" : "0"
	end

	def shipping_temperatures
		temperature_setting = { 
			"kakiset302" => "2",
			"kakiset202" => "2",
			"kakiset301" => "2",
			"kakiset201" => "2",
			"kakiset101" => "2",
			"karatsuki100" => "2",
			"karatsuki50" => "2",
			"karatsuki40" => "2",
			"karatsuki30" => "2",
			"karatsuki20" => "2",
			"karatsuki10" => "2",
			"mukimi04" => "2",
			"mukimi03" => "2",
			"mukimi02" => "2",
			"mukimi01" => "2",
			"pkara100" => "1",
			"pkara50" => "1",
			"pkara40" => "1",
			"pkara30" => "1",
			"pkara20" => "1",
			"pkara10" => "1",
			"pmuki04" => "1",
			"pmuki03" => "1",
			"pmuki02" => "1",
			"pmuki01" => "1",
			"tako1k" => "2",
			"mebi80x5" => "2",
			"mebi80x3" => "2",
			"hebi80x10" => "2",
			"hebi80x5" => "2",
			"anago600" => "2",
			"anago480" => "2",
			"anago350" => "2" }
		item_ids.map{|i| temperature_setting[i]}.uniq
	end

	def shipping_arrival_date
		two_day_prefectures = ["北海道", "青森県", "秋田県", "岩手県", "長崎県", "沖縄県", "鹿児島県"]
		self.ship_date.nil? ? ship_date = Date.today : ship_date = self.ship_date
		unless self.shipping_details["ShipRequestDate"]
			unless two_day_prefectures.include?(self.shipping_details["ShipPrefecture"])
				(ship_date + 1.day)
			else
				(ship_date + 2.day)
			end
		else
			Date.parse(self.shipping_details["ShipRequestDate"])
		end
	end

	def yamato_arrival_time
		req_time = self.shipping_details["ShipRequestTime"]
		if req_time
			conversion_hash = {
				"08:00-12:00" => "0812",
				"09:00-12:00" => "0812",
				"14:00-16:00" => "1416",
				"16:00-18:00" => "1618",
				"18:00-19:00" => "1820",
				"19:00-21:00" => "1921"
			}
			conversion_hash.keys.include?(req_time) ? conversion_hash[req_time] : req_time
		else
			""
		end
	end

	def arrival_time
		(self.shipping_details["ShipRequestTime"].nil? ? "指定無し" : self.shipping_details["ShipRequestTime"])
	end

	def tracking
		self.shipping_details["ShipInvoiceNumber1"]
	end

	def tracking_url
		'https://jizen.kuronekoyamato.co.jp/jizen/servlet/crjz.b.NQ0010?id=' + self.tracking
	end

	def yamato_shipping_format
		require "moji"
		[	#送り状種類
			self.shipping_type, 
			#クール区分
			self.shipping_temperature, 
			#出荷予定日
			(self.ship_date || Date.today).strftime("%Y/%m/%d"), 
			#お届け予定日
			self.shipping_arrival_date.strftime("%Y/%m/%d"), 
			#配達時間帯
			self.yamato_arrival_time, 
			#お届け先電話番号
			self.shipping_phone, 
			#お届け先電話番号枝番
			"", 
			#お届け先郵便番号
			self.shipping_details["ShipZipCode"], 
			#お届け先住所
			self.shipping_details["ShipPrefecture"] + self.shipping_details["ShipCity"] + self.shipping_details["ShipAddress1"], 
			#お届け先アパートマンション名
			"", 
			#お届け先会社・部門１
			self.shipping_details["ShipAddress2"], 
			#お届け先会社・部門２
			"", 
			#お届け先名
			self.shipping_name, 
			#お届け先名(ｶﾅ)
			Moji.zen_to_han(self.shipping_name_kana), 
			#敬称
			"様", 
			#ご依頼主電話番号
			self.billing_phone, 
			#ご依頼主郵便番号
			self.billing_details["BillZipCode"], 
			#ご依頼主住所
			self.billing_details["BillPrefecture"] + self.billing_details["BillCity"] + self.billing_details["BillAddress1"], 
			#ご依頼主アパートマンション
			self.billing_details["BillAddress2"], 
			#ご依頼主名
			self.billing_name, 
			#ご依頼主名(ｶﾅ)
			Moji.zen_to_han(self.billing_name_kana), 
			#品名コード１
			self.item_details["ProductId"], 
			#品名１
			self.item_name + self.print_quantity, 
			#品名コード２
			"", 
			#品名２
			"", 
			#荷扱い１
			"ナマモノ", 
			#荷扱い２
			"天地無用", 
			#記事
			"", 
			#請求先顧客コード
			"079143655602", 
			#運賃管理番号
			"01"]
	end

end
