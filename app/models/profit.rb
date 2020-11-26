class Profit < ApplicationRecord
	before_save :set_ampm

	has_many :profit_and_market_joins
	has_many :markets, through: :profit_and_market_joins
	has_many :profit_and_product_joins
	has_many :products, through: :profit_and_product_joins
	serialize :figures
	serialize :totals
	serialize :subtotals
	serialize :volumes

	attr_accessor :new_figures

	validates :figures, 
		presence: true,
		length: { minimum: 1 }
	validates :sales_date,
		presence: true,
		length: { minimum: 1 }

	include OrderQuery
	order_query :profit_query,
		[:sales_date] # Sort :sales_date in :desc order

	## Reference for accessing data from the figures hash
	# self.figures.each do |type_number, type_hash|
	# 	type_hash.each do |product_id, product_hash|
	# 		product_hash.each do |market_id, values_hash|
	# 			values_hash[:order_count] => (floating-point)
	# 			values_hash[:unit_price ] => (floating-point)
	# 			values_hash[:combined] => (0=false/1=true)
	# 			values_hash[:extra_cost] => (0=false/1=true)
	# 		end
	# 	end
	# end

	def date
		DateTime.strptime(self.sales_date, "%Y年%m月%d日")
	end

	def alone?
		Profit.where(sales_date: self.sales_date).length == 1
	end

	def check_ampm
		# Tokyo will always be shipped in the AM
		self.market_ids.include?(Market.find_by(nick: '東水').id)
	end

	def set_ampm
		self.alone? ? () : (self.ampm = check_ampm)
	end

	def check_completion
		unfinished = Hash.new
		unfinished[0] = 0
		if self.figures && !self.figures[0]
			self.figures.each do |type_number, type_hash|
				type_hash.each do |product_id, product_hash|
					if Product.find(product_id).profitable
						product_hash.each do |market_id, values_hash|
							if (values_hash[:order_count] != 0) && (values_hash[:unit_price] == 0)
								mjsnumber = Market.find(market_id).mjsnumber
								unfinished[mjsnumber].nil? ? unfinished[mjsnumber] = Array.new : ()
								unfinished[mjsnumber] << product_id
								unfinished[0] += 1
							end
						end
					end
				end
			end
		end
		unfinished
	end

	def get_total_rankings
		stats_hash = Hash.new
		self.subtotals.each do |k, v|
			if k.respond_to?('to_i')
				if v.is_a?(Hash)
					v.each do |product_number, values|
						if product_number.respond_to?('to_i')
							stats_hash[product_number] = values
						end
					end
				end
			end
		end
		stats_hash.sort_by { |k,v| v[:product_boxes_sold] }.reverse
	end

	def get_type_rankings
		stats_hash = Hash.new
		self.subtotals.each do |k, v|
			if k.respond_to?('to_i')
				!stats_hash[k].is_a?(Hash) ? stats_hash[k] = Hash.new : ()
				if v.is_a?(Hash)
					v.each do |product_number, values|
						if product_number.respond_to?('to_i')
							stats_hash[k][product_number] = values
						end
					end
				end
			end
		end
		stats_hash
	end

	def mizukiri_figures
		mizukiri_figures = Hash.new
		mizukiri_figures[:gohyaku_total] = 0
		mizukiri_figures[:kilo_total] = 0
		mizukiri_figures[:gohyaku_profits] = 0
		mizukiri_figures[:kilo_profits] = 0
		self.subtotals.each do |k, v|
			if k.respond_to?('to_i')
				if k == "3"
					if v.is_a?(Hash)
						v.each do |product_number, values|
							if product_number.respond_to?('to_i')
								if values[:product_name].include?("500g")
									mizukiri_figures[:gohyaku_total] += values[:products_sold]
									mizukiri_figures[:gohyaku_profits] += values[:product_sales] - values[:product_expenses]
								end
								if values[:product_name].include?("1キロ")
									mizukiri_figures[:kilo_total] += values[:products_sold]
									mizukiri_figures[:kilo_profits] += values[:product_sales] - values[:product_expenses]
								end
							end
						end
					end
				end
			end
		end
		(mizukiri_figures[:gohyaku_total] != 0) ? (mizukiri_figures[:gohyaku_tanka] = ((mizukiri_figures[:gohyaku_profits] / mizukiri_figures[:gohyaku_total]) * 2).to_i) : (mizukiri_figures[:gohyaku_tanka] = 0)
		(mizukiri_figures[:kilo_total]) != 0 ? (mizukiri_figures[:kilo_tanka] = (mizukiri_figures[:kilo_profits] / mizukiri_figures[:kilo_total]).to_i) : (mizukiri_figures[:kilo_tanka] = 0)
		
		
		mizukiri_figures
	end

	def do_autosave
		def set_figures(figures_hash, type_number, product_id, market_id, values_hash)
			figures_hash[type_number] = Hash.new unless figures_hash[type_number].is_a?(Hash)
			figures_hash[type_number][product_id] = Hash.new unless figures_hash[type_number][product_id].is_a?(Hash)
			figures_hash[type_number][product_id][market_id] = Hash.new unless figures_hash[type_number][product_id][market_id].is_a?(Hash)
			figures_hash[type_number][product_id][market_id][:order_count] = values_hash["order_count"].to_f
			figures_hash[type_number][product_id][market_id][:unit_price] = values_hash["unit_price"].to_f
			figures_hash[type_number][product_id][market_id][:combined] = values_hash["combined"].to_i
			figures_hash[type_number][product_id][market_id][:extra_cost] = values_hash["extra_cost"].to_i
		end
		original_figures = self.figures
		new_figures = Hash.new 
		new_figures = self.new_figures
		new_figures.deep_transform_keys! { |k| k.scan(/^\d+$/).any? ? (k.to_i) : (k.to_s.to_sym) }
		parsed_figures = Hash.new
		new_figures.each do |type_number, type_hash|
			type_hash.each do |product_id, product_hash|
				product_hash.each do |market_id, values_hash|
					if values_hash["order_count"].to_f > 0 || values_hash["unit_price"].to_f > 0
						set_figures(parsed_figures, type_number, product_id, market_id, values_hash)
					end
					if !original_figures.dig(type_number, product_id, market_id).nil?
						set_figures(parsed_figures, type_number, product_id, market_id, values_hash)
						if values_hash["order_count"].to_f == 0 || values_hash["unit_price"].to_f == 0
							original_figures[type_number][product_id].delete(market_id)
							if original_figures[type_number][product_id].empty?
								original_figures[type_number].delete(product_id)
								if original_figures[type_number].empty?
									original_figures.delete(type_number)
									ap "emptied..."
								end
							end
						end
					end
				end
			end
		end
		merged_figures = original_figures.deep_merge(parsed_figures)
		merged_figures[0] ? merged_figures.delete(0) : ()
		self.figures = merged_figures
	end

	def calculate_tab
		# Replace Associations
		associated_products = Set.new
		associated_markets = Set.new
		costs = Array.new
		sales = Array.new
		extras = 0
		# Make Calculations
		parsed_figures = Hash.new
		self.figures.each do |type_number, type_hash|
			type_hash.each do |product_id, product_hash|
				#set associated product
				associated_products << product_id
				#set units per box per order
				product_record = Product.find(product_id)
				unit_multiplier = product_record.count * product_record.multiplier
				product_hash.each do |market_id, values_hash|
					unless (values_hash[:order_count].zero? && values_hash[:order_count].zero?)
						#reformulate the figures hash without empty figures
						parsed_figures[type_number] = Hash.new unless parsed_figures[type_number].is_a?(Hash)
						parsed_figures[type_number][product_id] = Hash.new unless parsed_figures[type_number][product_id].is_a?(Hash)
						parsed_figures[type_number][product_id][market_id] = Hash.new unless parsed_figures[type_number][product_id][market_id].is_a?(Hash)
						parsed_figures[type_number][product_id][market_id][:order_count] = values_hash[:order_count]
						parsed_figures[type_number][product_id][market_id][:unit_price] = values_hash[:unit_price]
						parsed_figures[type_number][product_id][market_id][:combined] = values_hash[:combined]
						parsed_figures[type_number][product_id][market_id][:extra_cost] = values_hash[:extra_cost]
						#set associated market
						associated_markets << market_id
						#add profit from this product sales to array
						market_record = Market.find(market_id)
						this_sale = ((values_hash[:unit_price] * values_hash[:order_count] * unit_multiplier) * market_record.handling)
						!this_sale.zero? ? sales << this_sale : ()
						#add costs per unit
						product_cost = product_record.cost.to_f
						market_shipping = market_record.cost.to_f + market_record.block_cost.to_f
						if !values_hash[:order_count].zero?
							costs << (values_hash[:order_count] * product_cost)
							#also take the market shipping cost and multiply it by the number of boxes ordered to add to costs
							#if it's a brokerage shipping needs to be added manually as if a product.
							if !market_record.brokerage
								costs << (values_hash[:order_count] * market_shipping)
							end
						end
						if !values_hash[:extra_cost].zero?
							extras += (values_hash[:order_count] * market_record.optional_cost)
						end
						if !values_hash[:combined].zero?
							extras -= market_shipping
						end
					end
				end
			end
		end

		#add the daily costs for each market (money transfer and fax/data fees)
		associated_markets.each do |market_id|
			market_record = Market.find(market_id)
			extras += market_record.one_time_cost.to_f
		end

		#set the profit for saving
		self.figures = parsed_figures
		self.product_ids = associated_products
		self.market_ids = associated_markets
		total_expenses = 0
		total_sales = 0
		costs.each do |cost|
			total_expenses += cost
		end
		sales.each do |sales|
			total_sales += sales
		end
		self.totals = Hash.new
		self.totals[:sales] = total_sales
		self.totals[:expenses] = total_expenses
		self.totals[:extras] = extras
		self.totals[:profits] = total_sales - total_expenses - extras
	end

	def calculate_volumes
		product_volumes = Hash.new
		market_volumes = Hash.new
		total_sold = 0
		total_volume = 0
		magic_number = ENV['MAGIC_NUMBER'] ? (ENV['MAGIC_NUMBER']).to_f : 1
		self.figures.each do |type_number, type_hash|
			product_volumes[type_number] = Hash.new if product_volumes[type_number].nil?
			product_volumes[type_number][:total] = 0 if product_volumes[type_number][:total].nil?
			product_volumes[type_number][:count] = 0 if product_volumes[type_number][:count].nil?
			type_hash.each do |product_id, product_hash|
				product_volumes[type_number][product_id] = Hash.new if product_volumes[type_number][product_id].nil?
				product_volumes[type_number][product_id][:total] = 0 if product_volumes[type_number][product_id][:total].nil?
				product_volumes[type_number][product_id][:count] = 0 if product_volumes[type_number][product_id][:count].nil?
				product = Product.find(product_id)
				grams = product.grams * (type_number == 3 ? 1 : magic_number)
				count = product.count
				multiplier = product.multiplier
				product_volumes[type_number][product_id][:name] = product.namae
				product_volumes[type_number][product_id][:grams] = grams
				product_volumes[type_number][product_id][:multiplier] = multiplier
				product_hash.each do |market_id, values_hash|
					products_sold = values_hash[:order_count] * count * multiplier
					product_volumes[type_number][:count] += products_sold
					total_sold += products_sold
					subtotal = grams * products_sold
					total_volume += subtotal
					product_volumes[type_number][:total] += subtotal
					product_volumes[type_number][product_id][:total] += subtotal
					product_volumes[type_number][product_id][:count] += products_sold
					market = Market.find(market_id)
					product_volumes[type_number][product_id][market.mjsnumber] = Hash.new if product_volumes[type_number][product_id][market.mjsnumber].nil?
					product_volumes[type_number][product_id][market.mjsnumber][:nick] = market.nick
					product_volumes[type_number][product_id][market.mjsnumber][:color] = market.color
					product_volumes[type_number][product_id][market.mjsnumber][:count] = products_sold
					product_volumes[type_number][product_id][market.mjsnumber][:id] = market.id
					product_volumes[type_number][product_id][market.mjsnumber][:total] = 0 if product_volumes[type_number][product_id][market.mjsnumber][:total].nil?
					product_volumes[type_number][product_id][market.mjsnumber][:total] += subtotal
					market_volumes[market.mjsnumber] = Hash.new if market_volumes[market.mjsnumber].nil?
					market_volumes[market.mjsnumber][:nick] = market.nick
					market_volumes[market.mjsnumber][:color] = market.color
					market_volumes[market.mjsnumber][:id] = market.id
					market_volumes[market.mjsnumber][:count] = 0 if market_volumes[market.mjsnumber][:count].nil?
					market_volumes[market.mjsnumber][:count] += products_sold
					market_volumes[market.mjsnumber][:total] = 0 if market_volumes[market.mjsnumber][:total].nil?
					market_volumes[market.mjsnumber][:total] += subtotal
					market_volumes[market.mjsnumber][product_id] = Hash.new if market_volumes[market.mjsnumber][product_id].nil?
					market_volumes[market.mjsnumber][product_id][:name] = product.namae
					market_volumes[market.mjsnumber][product_id][:grams] = grams
					market_volumes[market.mjsnumber][product_id][:count] = products_sold
					market_volumes[market.mjsnumber][product_id][:multiplier] = multiplier
					market_volumes[market.mjsnumber][product_id][:total] = 0 if market_volumes[market.mjsnumber][product_id][:total].nil?
					market_volumes[market.mjsnumber][product_id][:total] += subtotal
				end
			end
		end
		volumes = {product_volumes: product_volumes, market_volumes: market_volumes, total_sold: total_sold, total_volume: total_volume, magic_number: magic_number}
		volumes
	end

	def fix_figures
		@types_numbers_hash = {"トレイ"=>"1", "チューブ"=>"2", "水切り"=>"3", "殻付き"=>"4", "冷凍"=>"5", "単品"=>"6"}
		@types_with_products_hash = Hash.new
		Product.all.each do |product|
			type_number = @types_numbers_hash[product.product_type]
			@types_with_products_hash[type_number].is_a?(Array) ? () : (@types_with_products_hash[type_number] = Array.new)
			@types_with_products_hash[type_number] << product.id
		end
		fixed_hash = Hash.new
		self.figures.each do |type_number, type_hash|
			type_hash.each do |product_number, product_hash|
				product_hash.each do |market_number, values_hash|
					#some old records have nil values and were not automatically emptied from the hash yet, excluding those
					if !values_hash[:order_count].nil? && !values_hash[:unit_price].nil?
						if values_hash[:order_count] > 0 || values_hash[:unit_price] > 0
							# Some early figures have a values hash without combined and extra_cost values, adding them now
							values_hash[:combined].nil? ? (values_hash[:combined] = 0.0) : ()
							values_hash[:extra_cost].nil? ? (values_hash[:extra_cost] = 0.0) : ()
							#check to make sure to enumerated type is correctly associated with it's product and remake the figures hash
							if !@types_with_products_hash[type_number.to_s].include?(product_number)
								@types_with_products_hash.each do |type_id, product_ids|
									if product_ids.include?(product_number)
										@correct_type_id = type_id
									end
								end
								fixed_hash[@correct_type_id.to_i] ? () : (fixed_hash[@correct_type_id.to_i] = Hash.new)
								fixed_hash[@correct_type_id.to_i][product_number] ? () : (fixed_hash[@correct_type_id.to_i][product_number] = Hash.new)
								fixed_hash[@correct_type_id.to_i][product_number][market_number] ? () : (fixed_hash[@correct_type_id.to_i][product_number][market_number] = Hash.new)
								fixed_hash[@correct_type_id.to_i][product_number][market_number] = values_hash
							else
								fixed_hash[type_number] ? () : (fixed_hash[type_number] = Hash.new)
								fixed_hash[type_number][product_number] ? () : (fixed_hash[type_number][product_number] = Hash.new)
								fixed_hash[type_number][product_number][market_number] ? () : (fixed_hash[type_number][product_number][market_number] = Hash.new)
								fixed_hash[type_number][product_number][market_number] = values_hash
							end
						end
					end
				end
			end
		end
		self.figures = fixed_hash
		self.save
	end

	def sanbyaku_extra_cost_fix
		markets = [8, 9, 23, 24]
		i = 0
		markets.each do |m|
			if self.figures.dig(1,24,m,:extra_cost) == 0
				self.figures[1][24][m][:extra_cost] = 1
				i += 1
			end
		end
		if i > 0
			self.calculate_tab
			self.subtotals = self.get_subtotals
			self.save
		end
		'Profit #' + self.id.to_s + ' from ' + self.sales_date + ' was fixed.'
	end

	def get_subtotals
		figs_hash = self.figures
		#set up types hash (number as key, type as value)
		@types_hash = {"1"=>"トレイ", "2"=>"チューブ", "3"=>"水切り", "4"=>"殻付き", "5"=>"冷凍", "6"=>"単品"}
		subtotals = Hash.new
		subtotals[:extra_costs] = Hash.new
		total_products_sold_value = 0
		total_boxes_used_value = 0
		if figs_hash[0] != 0
			figs_hash.each do |type_id, product_hash|
				#reset value counter for each type based value
				type_products_sold_value = 0
				type_boxes_used_value = 0
				type_expenses_value = 0
				type_sales_value = 0

				product_hash.each do |product_id, market_hash|
					#reset value counter for each product based value
					products_sold_value = 0
					products_boxes_used_value = 0
					product_expenses_value = 0
					product_sales_value = 0

					market_hash.each do |market_id, value_hash|
						#set up the variables
						current_product = Product.find(product_id)
						current_market = Market.find(market_id)

						#type to hash, add name, unless it's already there
						subtotals[type_id.to_s] = Hash.new unless subtotals[type_id.to_s].is_a?(Hash)
						subtotals[type_id.to_s][:type_name] = @types_hash[type_id.to_s]

						#in case the user has no input values for a market that they enabled, or the form was autosaved without them.
						if value_hash[:order_count].nil?
							value_hash[:order_count] = 0
						end
						if value_hash[:unit_price].nil?
							value_hash[:unit_price] = 0
						end

						####################################
						####### BEGIN TYPE SUBTOTALS #######
						####################################

						## PRODUCTS COUNT BY TYPE
						#take the order count and multiply it by products per package and then add it to the product count value hash
						if type_products_sold_value == 0
							type_products_sold_value = value_hash[:order_count] * current_product.count.to_f * current_product.multiplier.to_f
						else
							type_products_sold_value += value_hash[:order_count] * current_product.count.to_f * current_product.multiplier.to_f
						end
						subtotals[type_id.to_s][:type_products_sold] = type_products_sold_value.to_f
						#take the same math from the type_products_sold_value but don't reset the counter to find total
						if total_products_sold_value == 0
							total_products_sold_value = value_hash[:order_count] * current_product.count.to_f * current_product.multiplier.to_f
						else
							total_products_sold_value += value_hash[:order_count] * current_product.count.to_f * current_product.multiplier.to_f
						end
						subtotals[:total_products_sold] = total_products_sold_value.to_f

						## BOXES COUNT BY TYPE
						#take the order count and multiply it be the "mulitplier" aka the boxes 合わせ
						if type_boxes_used_value == 0
							type_boxes_used_value = value_hash[:order_count] * current_product.multiplier.to_f
						else
							type_boxes_used_value += value_hash[:order_count] * current_product.multiplier.to_f
						end
						subtotals[type_id.to_s][:type_boxes_used] = type_boxes_used_value.to_f
						## BOXES COUNT TOTAL
						#take the same math from the type_boxes_used_value but don't reset the counter to find total
						if total_boxes_used_value == 0
							total_boxes_used_value= value_hash[:order_count] * current_product.multiplier.to_f
						else
							total_boxes_used_value += value_hash[:order_count] * current_product.multiplier.to_f
						end
						subtotals[:total_boxes_used] = total_boxes_used_value.to_f

						## SUBTOTAL EXPENSES BY TYPE
						#take the (boxes sold * shipping cost) and (boxes sold * product cost) and add to the expense by type subtotal
						if type_expenses_value == 0
							if !current_market.brokerage
								type_expenses_value = value_hash[:order_count] * (current_market.cost.to_f + current_market.block_cost.to_f + current_product.cost.to_f)
							else
								type_expenses_value = value_hash[:order_count] * (current_product.cost.to_f)
							end
						else
							if !current_market.brokerage
								type_expenses_value += value_hash[:order_count] * (current_market.cost.to_f + current_market.block_cost.to_f + current_product.cost.to_f)
							else
								type_expenses_value += value_hash[:order_count] * (current_product.cost.to_f)
							end
						end
						subtotals[type_id.to_s][:type_expenses] = type_expenses_value.to_f

						## SUBTOTAL SALES BY TYPE
						#take the (boxes sold * shipping cost) and (boxes sold * product cost) and add to the expense by type subtotal
						unit_multiplier = current_product.count * current_product.multiplier
						if type_sales_value == 0
							type_sales_value = (value_hash[:unit_price] * value_hash[:order_count] * unit_multiplier) * current_market.handling.to_f
						else
							type_sales_value += (value_hash[:unit_price] * value_hash[:order_count] * unit_multiplier) * current_market.handling.to_f
						end
						subtotals[type_id.to_s][:type_sales] = type_sales_value.to_f


						####################################
						##### BEGIN PRODUCTS SUBTOTALS #####
						####################################

						#make a hash to store the product subtotals
						subtotals[type_id.to_s][product_id.to_s] = Hash.new unless subtotals[type_id.to_s][product_id.to_s].is_a?(Hash)
						subtotals[type_id.to_s][product_id.to_s][:product_name] = current_product.namae

						## PRODUCTS COUNT BY PRODUCT
						#take the (boxes sold * shipping cost) and (boxes sold * product cost) and add to the expense by type subtotal
						if products_sold_value == 0
							products_sold_value = value_hash[:order_count] * current_product.count.to_f * current_product.multiplier.to_f
						else
							products_sold_value += value_hash[:order_count] * current_product.count.to_f * current_product.multiplier.to_f
						end
						subtotals[type_id.to_s][product_id.to_s][:products_sold] = products_sold_value

						## PRODUCTS BOXES BY PRODUCT
						#take the (boxes sold * shipping cost) and (boxes sold * product cost) and add to the expense by product subtotal
						if products_boxes_used_value == 0
							products_boxes_used_value = value_hash[:order_count]  * current_product.multiplier.to_f
						else
							products_boxes_used_value += value_hash[:order_count] * current_product.multiplier.to_f
						end
						subtotals[type_id.to_s][product_id.to_s][:product_boxes_sold] = products_boxes_used_value

						## SUBTOTAL EXPENSES BY PRODUCT
						#take the (boxes sold * shipping cost) and (boxes sold * product cost) and add to the expense by product subtotal
						if product_expenses_value == 0
							if !current_market.brokerage
								product_expenses_value = value_hash[:order_count] * (current_market.cost.to_f + current_market.block_cost.to_f + current_product.cost.to_f)
							else
								product_expenses_value = value_hash[:order_count] * (current_product.cost.to_f)
							end
						else
							if !current_market.brokerage
								product_expenses_value += value_hash[:order_count] * (current_market.cost.to_f + current_market.block_cost.to_f + current_product.cost.to_f)
							else
								product_expenses_value += value_hash[:order_count] * (current_product.cost.to_f)
							end
						end
						subtotals[type_id.to_s][product_id.to_s][:product_expenses] = product_expenses_value.to_f

						## SUBTOTAL SALES BY PRODUCT
						#take the (boxes sold * shipping cost) and (boxes sold * product cost) and add to the expense by product subtotal
						if product_sales_value == 0
							product_sales_value = (value_hash[:unit_price] * value_hash[:order_count] * unit_multiplier) * current_market.handling.to_f
						else
							product_sales_value += (value_hash[:unit_price] * value_hash[:order_count] * unit_multiplier) * current_market.handling.to_f
						end
						subtotals[type_id.to_s][product_id.to_s][:product_sales] = product_sales_value.to_f


						####################################
						#####    BEGIN SPECIAL COSTS   #####
						####################################

						#set up the hash, unless it's there, set it to 0, unless it's more than zero, and add each positive returned awase
						subtotals[:extra_costs][market_id.to_s] = Hash.new unless subtotals[:extra_costs][market_id.to_s].is_a?(Hash)
						subtotals[:extra_costs][market_id.to_s][:awase_count] = 0 unless !subtotals[:extra_costs][market_id.to_s][:awase_count].nil?
						subtotals[:extra_costs][market_id.to_s][:awase_count] += value_hash[:combined].to_f
						#set up the hash, unless it's there, set it to 0, unless it's more than zero, and add each positive returned awase
						subtotals[:extra_costs][market_id.to_s] = Hash.new unless subtotals[:extra_costs][market_id.to_s].is_a?(Hash)
						subtotals[:extra_costs][market_id.to_s][:extra_costs_count] = 0 unless !subtotals[:extra_costs][market_id.to_s][:extra_costs_count].nil?
						subtotals[:extra_costs][market_id.to_s][:extra_costs_count] += value_hash[:extra_cost].to_f * value_hash[:order_count]

					end
				end
			end
		end
		subtotals
	end

end
