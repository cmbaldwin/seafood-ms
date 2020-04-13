class Market < ApplicationRecord
	has_many :product_and_market_joins
	has_many :products, through: :product_and_market_joins
	has_many :profit_and_market_joins
	has_many :profits, through: :profit_and_market_joins
	serialize :history

	validates :namae, 
		presence: true,
		length: { minimum: 1 }
	validates :address, 
		presence: true,
		length: { minimum: 1 }
	validates :phone, 
		presence: true,
		length: { minimum: 1 }
	validates :repphone, 
		presence: true,
		length: { minimum: 1 }
	validates :fax, 
		presence: true,
		length: { minimum: 1 }
	validates :cost, 
		presence: true,
		length: { minimum: 1 }


	def do_history
		current = Array.new
		current << self.namae.to_s
		current << self.nick.to_s
		current << self.color.to_s
		current << self.brokerage
		current << self.address.to_s
		current << self.phone.to_s
		current << self.repphone.to_s
		current << self.mjsnumber.to_s
		current << self.block_cost.to_s
		current << self.handling.to_s
		current << self.fax.to_s
		current << self.cost.to_s
		current << self.one_time_cost.to_s
		current << self.one_time_cost_description.to_s
		current << self.optional_cost.to_s
		current << self.optional_cost_description.to_s
		self.history["#{Time.now}"] = current
	end

	def do_stats
		stats = Hash.new
		stats[:products] = Hash.new
		stats[:totals] = Hash.new
		symbols = [:ordered, :prices, :total_sales]
		Profit.all.each do |profit|
			profit.figures.each do |type, type_hash|
				type_hash.each do |product, product_hash|
					current_product = Product.find(product)
					product_hash.each do |market, market_hash|
						if market == self.id
							stats[:products][product].nil? ? stats[:products][product] = Hash.new : ()
							symbols.each do |symbol|
								stats[:products][product][symbol].nil? ? stats[:products][product][symbol] = Array.new : ()
							end
							stats[:products][product][:ordered] << market_hash[:order_count].to_i
							stats[:products][product][:prices] << market_hash[:unit_price].to_i
							stats[:products][product][:total_sales] << (market_hash[:order_count] * (current_product.count * current_product.multiplier * market_hash[:unit_price])).to_i
						end
					end
				end
			end
		end
		stats[:totals][:total_sales] = 0
		stats[:products].each do |product, product_hash|
			prices = product_hash[:prices]
			current_product = Product.find(product)
			product_hash[:mean_price] = prices[prices.length / 2]
			product_hash[:average_price_by_prices] = product_hash[:prices].sum / product_hash[:prices].length
			product_hash[:average_price_by_sales] = (product_hash[:total_sales].sum / (current_product.count * current_product.multiplier * product_hash[:ordered].sum ))
			stats[:totals][:total_sales].nil? ? (stats[:totals][:total_sales] = product_hash[:total_sales].sum) : (stats[:totals][:total_sales] += product_hash[:total_sales].sum)
			stats[:totals][:total_boxes_ordered].nil? ? (stats[:totals][:total_boxes_ordered] = product_hash[:ordered].sum) : (stats[:totals][:total_boxes_ordered] += product_hash[:ordered].sum)
		end
		self.history[:stats] = stats
		self.save
	end

end
