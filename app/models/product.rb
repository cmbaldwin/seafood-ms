class Product < ApplicationRecord
	has_many :product_and_material_joins
	has_many :materials, through: :product_and_material_joins
	has_many :product_and_market_joins
	has_many :markets, through: :product_and_market_joins
	has_many :profit_and_product_joins
	has_many :profits, through: :profit_and_product_joins
	serialize :history
	serialize :infomart_association

	validates :namae, 
		presence: true,
		length: { minimum: 1 }
	validates :count, 
		presence: true,
		length: { minimum: 1 }
	validates :multiplier, 
		presence: true,
		length: { minimum: 1 }
	validates :cost, 
		presence: true,
		length: { minimum: 1 }

	def do_stats
		stats = Hash.new
		stats[:markets] = Hash.new
		stats[:totals] = Hash.new
		stats[:totals][:total_sales] = 0
		Market.all.each do |m|
			market_stats = m.history[:stats][:products][self.id]
			if !market_stats.nil?
				stats[:markets][m.id].nil? ? stats[:markets][m.id] = Hash.new : ()
				stats[:markets][m.id][:total_ordered].nil? ? stats[:markets][m.id][:total_ordered] = market_stats[:ordered].sum : stats[:markets][m.id][:total_ordered] += market_stats[:ordered].sum
				stats[:markets][m.id][:total_sales].nil? ? stats[:markets][m.id][:total_sales] = market_stats[:total_sales].sum : stats[:markets][m.id][:total_sales] += market_stats[:total_sales].sum
				stats[:totals][:total_sales] += market_stats[:total_sales].sum
			end
		end
		self.history[:stats] = stats
		self.save
	end

	def refresh_history
		current = Array.new
		current << self.product_type.to_s
		current << self.profitable.to_s
		current << self.grams.to_s
		current << self.cost.to_s
		current << self.extra_expense.to_s
		current << self.count.to_s
		current << self.multiplier.to_s
		current << self.market_ids
		current << self.material_ids
		self.history["#{Time.now}"] = current
		self.save
	end

	def type_check
		types = {"トレイ"=>"1", "チューブ"=>"2", "水切り"=>"3", "殻付き"=>"4", "冷凍"=>"5", "単品"=>"6"}
		!types.keys.include?(self.product_type) ? self.product_type = "単品" : ()
	end

	def get_estimate
		estimate = 0
		self.materials.each do |m|
			flattened_cost = m.cost * m.divisor
			((m.zairyou == '箱') || (m.zairyou == 'フタ') || (m.zairyou == '粒氷') || (m.zairyou == 'テープ')) ? (estimate += (flattened_cost * self.multiplier)) : ()
			if (m.zairyou == 'フィルム') || (m.zairyou == 'トレイ') || (m.zairyou == 'ラベル') || (m.zairyou == '袋')
				if m.per_product
					estimate += flattened_cost * self.multiplier * self.count
				else
					estimate += flattened_cost
				end
			end
			(m.zairyou == 'バンド') ? (estimate += flattened_cost) : ()
		end
		estimate
	end

	def do_product_pdf
		require "prawn"
		# document set up
		Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [25]) do |pdf|
			# set utf-8 japanese font
			pdf.font_families.update(PrawnPDF.fonts)
			pdf.font "SourceHan"
			pdf.font_size 16
			pdf.text '商品リスト'
			pdf.move_down 5
			pdf.font_size 8
			table_data = Array.new
				header = Array.new
				header << '#'
				header << '名前'
				header << 'グラム数
				0.0:                    /    0.2:                    /    0.4:                    '
				header << '経費'
				header << '入数'
				header << '合わせ箱数'
				header << '特別経費'
				table_data << header
			Product.all.order(:namae).each do |product|
				if product.profitable
					product_row = Array.new
					product_row << product.id.to_s
					product_row << product.namae.to_s
					product_row << '0.0:                    /    0.2:                    /    0.4:                    '
					product_row << product.cost.to_s
					product_row << product.count.to_s
					product_row << product.multiplier.to_s
					product_row << product.extra_expense.to_s
					table_data << product_row
				end
			end
			pdf.table(table_data, :cell_style => { :border_width => 0.25, :padding => 5, :inline_format => true }, :width => pdf.bounds.width, :column_widths => {2 => 200})
			return pdf
		end
	end

end