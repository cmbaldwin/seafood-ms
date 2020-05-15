class Restaurant < ApplicationRecord
	has_many :restaurant_and_manifest_joins
	has_many :manifests, through: :restaurant_and_manifest_joins

	serialize :products
	serialize :stats
	validates_presence_of :namae
	validates_uniqueness_of :namae
	validates_uniqueness_of :link

	def get_link
		"https://www2.infomart.co.jp/seller/search/company_detail.page?19&mcd=" + self.link.to_s
	end

	def do_stats
		stats = Hash.new
		stats[:raw_orders] = Hash.new
		stats[:chart] = Hash.new
		stats[:totals] = Hash.new
		Manifest.all.each do |manifest|
			if manifest.restaurants.pluck(:id).include?(self.id)
				manifest.infomart_orders.each do |type, order_hash|
					order_hash.each do |order_num, order_content|
						if order_content[:restaurant_id] == self.id
							stats[:raw_orders][manifest.sales_date] = order_content
							order_content[:items].each do |item_num, item_hash|
								stats[:chart][item_hash[:item_name]].is_a?(Hash) ? () : stats[:chart][item_hash[:item_name]] = Hash.new
								stats[:chart][item_hash[:item_name]][manifest.sales_date] = item_hash[:item_count]
								stats[:totals][manifest.sales_date[0..3]].is_a?(Hash) ? () : (stats[:totals][manifest.sales_date[0..3]] = Hash.new)
								stats[:totals][manifest.sales_date[0..3]][item_hash[:item_name]] ? (stats[:totals][manifest.sales_date[0..3]][item_hash[:item_name]] += item_hash[:item_count].to_i) : (stats[:totals][manifest.sales_date[0..3]][item_hash[:item_name]] = item_hash[:item_count].to_i)
							end
						end
					end
				end
			end
		end
		self.stats = stats
		self.save
	end

end
