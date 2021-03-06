module ProfitsHelper

	def types_hashes
		@products = Product.all
		@markets = Market.all
		#set up types hash (number as key, type as value)
		@types_hash = {"1"=>"トレイ", "2"=>"チューブ", "3"=>"水切り", "4"=>"殻付き", "5"=>"冷凍", "6"=>"単品"}
	end

	def type_to_text(type_str)
		{"1"=>"トレイ", "2"=>"チューブ", "3"=>"水切り", "4"=>"殻付き", "5"=>"冷凍", "6"=>"単品"}[(type_str)]
	end

	def get_product_grams(product_id)
		@product_data[product_id]["grams"].to_f
	end

	def get_product_name(product_id)
		@product_data[product_id]["namae"]
	end

	def get_product_cost(product_id)
		@product_data[product_id]["cost"].to_f
	end

	def get_product_box_count(product_id)
		@product_data[product_id]["multiplier"].to_f
	end

	def get_product_product_per_box(product_id)
		@product_data[product_id]["count"].to_f
	end

	def get_product_average_price(product_id)
		@product_data[product_id]["average_price"].to_f
	end

	def strange_price_check(product_id, unit_price)
		((unit_price > (get_product_average_price(product_id) * 1.51)) || (unit_price < (get_product_average_price(product_id) * 0.49))) ? 'text-danger' : 'text-info'
	end

	def adjust_totals(profits)
		adjust_totals = 0
		profits.each do |profit|
			adjust_totals += profit.totals[:profits]
		end
		adjust_totals
	end

	def active(i)
		(i == 0) ? 'active ' : ()
	end

	def profit_nav_font_color(color)
		(color == "#ffffff" || color == "#e3fffc" || color == "#f0f0f0" || color == "#efeff2") ? 'light-pill' : 'dark-pill'
	end

end
