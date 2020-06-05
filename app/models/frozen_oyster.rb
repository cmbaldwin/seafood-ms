class FrozenOyster < ApplicationRecord
	validates_presence_of :manufacture_date
	validates :manufacture_date, uniqueness: {scope: [:ampm]}
	serialize :finished_packs
	serialize :frozen_l
	serialize :frozen_ll
	serialize :losses

	before_save :set_nil_to_zero

	def set_nil_to_zero
		self.finished_packs.each do |k, v|
			v == "" ? self.finished_packs[k] = 0 : ()
		end
		if self.frozen_l.nil?
			self.frozen_l = Hash.new
			self.frozen_l["坂越　L"] = 0
		end
		if self.frozen_ll.nil?
			self.frozen_ll = Hash.new
			self.frozen_ll["坂越　LL"] = 0
			self.frozen_ll["日生　LL"] = 0
		end
		if self.losses.nil?
			self.losses = Hash.new
			self.losses["小"] = 0
			self.losses["ハネ"] = 0
		end
	end

	def fix_empty_products
		@frozen_products = Product.where(product_type: '冷凍')
		@frozen_products.each do |product|
			if self.finished_packs[product.id.to_s].nil?
				self.finished_packs[product.id.to_s] = 0
			end
		end
	end

	def stats
		stats = Hash.new
		stats[:raw_total] = self.hyogo_raw.to_f + self.okayama_raw.to_f
		stats[:frozen_total] = (self.frozen_l["坂越　L"].to_f) + self.frozen_ll["坂越　LL"].to_f + self.frozen_ll["日生　LL"].to_f
		stats[:finished_packs_total] = 0
		stats[:finished_shells_total] = 0
		self.finished_packs.each do |k, v|
			if !Product.find(k).namae.include?('セル')
				stats[:finished_packs_total] += v.to_f
			else
				stats[:finished_shells_total] += v.to_f
			end
		end
		stats["小"] = ((self.losses["小"].to_f / stats[:raw_total]) * 100).round(2).to_s + "%"
		stats["ハネ"] = (((self.losses["ハネ"].to_f / 2) / stats[:raw_total]) * 100).round(2).to_s + "%"
		stats[:raw_to_frozen_loss] = (-(((stats[:frozen_total] / (stats[:raw_total])) * 100) - 100).round(2)).to_s + "%"
		stats[:grams_to_pack] = stats[:raw_total] / stats[:finished_packs_total]
		stats
	end

	def year_to_date
		data = Hash.new
		#calculate year to date stats
		FrozenOyster.where(manufacture_date: current_season_upto(self.manufacture_date_to_datetime)).order(:manufacture_date).each do |fdata|
			fdata.finished_packs.each do |product_id, value|
				data[product_id].nil? ? (data[product_id] = value.to_i) : (data[product_id] += value.to_i)
			end
		end
		data
	end

	def chart_stats
		daily_chart = Hash.new
		daily_chart["坂越　L (㎏)"] = self.frozen_l["坂越　L"]
		daily_chart["坂越　LL (㎏)"] = self.frozen_ll["坂越　LL"]
		daily_chart["日生　LL (㎏)"] = self.frozen_ll["日生　LL"]
		daily_chart["小 (㎏)"] = self.losses["小"].to_f
		daily_chart["ハネ (㎏)"] = (self.losses["ハネ"].to_f / 2).to_s
		daily_chart
	end
end
