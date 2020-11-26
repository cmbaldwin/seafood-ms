class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true

	def yenify(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "")
	end

	def yenify_with_decimal(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "", precision: 1)
	end

	def sales_date_to_datetime
		DateTime.strptime(self.sales_date, "%Y年%m月%d日")
	end

	def manufacture_date_to_datetime
		DateTime.strptime(self.manufacture_date, "%Y年%m月%d日")
	end

	def to_nengapi(datetime)
		datetime.strftime("%Y年%m月%d日")
	end

	def current_season_upto(datetime)
		#return array of dates between the start of the returned record's season and the date of the record
		start = (datetime.month < 10) ? DateTime.new((datetime.year - 1), 10, 1) : DateTime.new(datetime.year, 10, 1)
		(start..datetime).map {|d| to_nengapi(d)}
	end

	def calculate_shipping(prefecture, city, box_sizes)
		shipping_cost_hash = { %w( 北海道 ) => {60 => 1540, 80 => 1740, 100 => 1940},
		%w( 青森県 岩手県 秋田県 ) => {60 => 900, 80 => 900, 100 => 900},
		%w( 山形県 宮城県 福島県 ) => {60 => 800, 80 => 800, 100 => 800},
		%w( 茨城県 栃木県 群馬県 山梨県 埼玉県 千葉県 東京都 神奈川県 ) => {60 => 700, 80 => 700, 100 => 700},
		%w( 新潟県 長野県 ) => {60 => 700, 80 => 700, 100 => 700},
		%w( 富山県 石川県 福井県 ) => {60 => 600, 80 => 600, 100 => 600},
		%w( 岐阜県 静岡県 愛知県 三重県 ) => {60 => 600, 80 => 600, 100 => 600},
		%w( 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県 ) => {60 => 600, 80 => 600, 100 => 600},
		%w( 鳥取県 島根県 岡山県 広島県 山口県 ) => {60 => 600, 80 => 600, 100 => 600},
		%w( 徳島県 香川県 愛媛県 高知県 ) => {60 => 600, 80 => 600, 100 => 600},
		%w( 福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 ) => {60 => 700, 80 => 700, 100 => 700},
		%w( 沖縄県 ) => {60 => 1240, 80 => 1740, 100 => 2240}}
		shipping = 0
		box_sizes.compact.each do |size|
			size == 100 ? shipping += 300 : shipping += 200 #cool shipping
			shipping_cost_hash.each {|k,v| (shipping += v[size] if k.include?(prefecture)) }
		end
		shipping
	end

end