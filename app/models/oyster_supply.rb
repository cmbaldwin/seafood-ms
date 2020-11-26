class OysterSupply < ApplicationRecord

	validates_presence_of :supply_date
	validates_uniqueness_of :supply_date
	serialize :oysters, Hash
	serialize :totals, Hash

	attr_accessor :location
	attr_accessor :start_date
	attr_accessor :end_date
	attr_accessor :export_format
	attr_accessor :password

	include OrderQuery
	order_query :oyster_supply_query,
		[:supply_date] # Sort :supply_date in :desc order

	def date
		DateTime.strptime(self.supply_date, "%Y年%m月%d日")
	end

	def okayama_keys
		[:hinase, :tamatsu, :iri, :mushiage]
	end

	def okayama_key_str(key)
		{:hinase => "日生", :tamatsu => "玉津", :iri => "伊里", :mushiage => "虫明"}
	end

	def weekday_japanese(num)
		#d.strftime("%w") to Japanese
		weekdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
		weekdays[num]
	end

	def type_to_japanese(type)
		japanese = {"large" => "むき身（大）", "small" => "むき身（小）", "eggy" => "むき身（卵）", "large_shells" => "殻付き（大）", "small_shells" => "殻付き（小）", "thin_shells" => "殻付き（バラ）"}
		japanese[type]
	end

	def type_to_unit(type)
		japanese = {"large" => "㎏", "small" => "㎏", "eggy" => "㎏", "large_shells" => "個", "small_shells" => "個", "thin_shells" => "㎏"}
		japanese[type]
	end

	def number_to_circular(num)
		conversion = {"1" => "①", "2" => "②", "3" => "③", "4" => "④", "5" => "⑤", "6" => "⑥", "7" => "⑦", "8" => "⑧", "9" => "⑨", "10" => "⑩", "11" => "⑪", "12" => "⑫", "13" => "⑬", "14" => "⑭", "15" => "⑮" }
		conversion[num] ? conversion[num] : ()
	end

	def kanji_am_pm(am_or_pm)
		conversion = { "am" => "午前", "pm" => "午後", "午前" => "am", "午後" => "pm" }
		conversion[am_or_pm] ? conversion[am_or_pm] : ()
	end

	def mukimi_total
		large_shucked_total + small_shucked_total + small_shucked_eggy_total + okayama_total
	end

	def okayama_total
		total = 0
		["hinase", "tamatsu", "iri", "mushiage"].each do |location|
			total += self.oysters["okayama"][location]["subtotal"].to_f unless self.oysters["okayama"].nil?
		end
		total
	end

	def large_shucked_total
		total = 0
		self.oysters['large'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def small_shucked_total
		total = 0
		self.oysters['small'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def small_shucked_eggy_total
		total = 0
		self.oysters['eggy'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def shells_total
		total = 0
		self.oysters['large_shells'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		self.oysters['small_shells'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def set_variables
		@sakoshi_suppliers = Supplier.where(location: '坂越').order(:supplier_number)
		@aioi_suppliers = Supplier.where(location: '相生').order(:supplier_number)
		@all_suppliers = @sakoshi_suppliers + @aioi_suppliers
		@receiving_times = ["am", "pm"]
		set_types
		@supplier_numbers = @sakoshi_suppliers.pluck(:id).map(&:to_s)
		@supplier_numbers += @aioi_suppliers.pluck(:id).map(&:to_s)
	end

	def set_types
		@types = ["large", "small", "eggy", "large_shells", "small_shells", "thin_shells"]
	end


	def cost_total
		sakoshi_mukimi_cost_total + okayama_mukimi_cost_total
	end

	def big_shell_avg_cost
		cost_total = 0
		shells_count = 0
		self.oysters['large_shells'].each do |supplier, amounts|
			cost_total += amounts["invoice"].to_f
			shells_count += amounts["volume"].to_f
		end
		shells_count == 0 ? 0.0 : cost_total / shells_count
	end

	def sakoshi_mukimi_cost_total
		set_variables
		total = 0
		["large", "small", "eggy"].each do |type|
			@supplier_numbers.each do |id|
				total += self.oysters[type][id]["invoice"].to_f
			end
		end
		total
	end

	def okayama_mukimi_cost_total
		total = 0
		["hinase", "tamatsu", "iri", "mushiage"].each do |location|
			total += self.oysters["okayama"][location]["invoice"].to_f unless self.oysters["okayama"].nil?
		end
		total
	end

	def set_totals
		unless self.oysters.empty?
			totals = Hash.new
			totals[:okayama_total] = okayama_total
			totals[:shell_total] = shells_total
			totals[:big_shell_avg_cost] = big_shell_avg_cost
			totals[:sakoshi_total] = large_shucked_total + small_shucked_total + small_shucked_eggy_total
			totals[:sakoshi_mukimi_cost_total] = sakoshi_mukimi_cost_total
			totals[:sakoshi_avg_kilo] = (totals[:sakoshi_total] == 0) ? 0.0 : (totals[:sakoshi_mukimi_cost_total] / totals[:sakoshi_total])
			totals[:okayama_mukimi_cost_total] = okayama_mukimi_cost_total
			totals[:okayama_avg_kilo] = ((totals[:okayama_total] == 0) ? 0.0 : (totals[:okayama_mukimi_cost_total] / totals[:okayama_total]))
			totals[:mukimi_total] = totals[:sakoshi_total] + okayama_total
			totals[:cost_total] = cost_total
			totals[:total_kilo_avg] = (totals[:mukimi_total] == 0) ? 0.0 : (totals[:cost_total] / totals[:mukimi_total])
			self.totals = totals
		end
	end

	def check_completion
		completion = Hash.new
		set_types
		@types.each do |type|
			self.oysters[type].each do |supplier_id, supply_hash|
				if (supply_hash["volume"]) != "0" && (supply_hash["price"] == "0")
					completion[type].nil? ? ((completion[type] = Array.new) && (completion[type] << supplier_id)) : (completion[type] << supplier_id)
				end
			end
		end
		completion["okayama"] = Array.new if completion["okayama"].nil?
		((completion["okayama"] << "hinase") if self.oysters[:okayama]["hinase"]["price"].to_s == "0") if self.oysters[:okayama]["hinase"]["subtotal"].to_s != "0"
		((completion["okayama"] << "iri") if self.oysters[:okayama]["iri"]["price"].to_s == "0" ) if self.oysters[:okayama]["iri"]["subtotal"].to_s != "0"
		self.oysters[:okayama]["tamatsu"].each do |sup_num, sup_hash|
			if sup_hash.is_a?(Hash)
				if (sup_hash["小"] != "0") || (sup_hash["小"] != "0")
					(completion["okayama"].to_s << "tamatsu") if sup_hash["price"].to_s == "0" 
				end
			end
		end
		self.oysters[:okayama]["mushiage"].each do |sup_num, sup_hash|
			if sup_hash.is_a?(Hash)
				if sup_hash["volume"].to_s != "0"
					(completion["okayama"].to_s << "mushiage") if sup_hash["price"].to_s == "0" 
				end
			end
		end
		completion.delete('okayama') if (!completion["okayama"].nil? && completion["okayama"].empty?)
		completion
	end

	def locked?
		used_supply_ids = OysterInvoice.all.map {|i| i.oyster_supplies.ids }.flatten
		used_supply_ids.include?(self.id)
	end

	def invoice
		OysterInvoice.all.map { |i| (i.oyster_supplies.ids.include?(self.id)) ? (i.id) : () }.compact.first
	end

	def check_errors
		set_variables
		errors = Hash.new
		prev = self.oyster_supply_query.previous.year_to_date
		@types.each do |type|
			self.oysters[type].each do |supplier_id, supplier_hash|
				if supplier_hash["volume"].to_i > 0
					last_price = prev[supplier_id][type]["price"].sort.reverse.last.to_i
					current_price = supplier_hash["price"].to_i
					if current_price != last_price
						if (current_price < last_price * 0.8) || (current_price > last_price * 1.2)
							errors[supplier_id].nil? ? (errors[supplier_id] = Hash.new) : ()
							errors[supplier_id][type] = Hash.new
							errors[supplier_id][type]["previous_price"] = last_price
							errors[supplier_id][type]["current_price"] = current_price
							errors[supplier_id][type]["should not be less than"] = last_price * 0.8
							errors[supplier_id][type]["should not be more than"] = last_price * 1.2
						end
					end
				end
			end
		end
		errors
	end

	def do_setup
		set_variables
		self[:oysters] = Hash.new if !self[:oysters].is_a?(Hash)
		self[:oysters]["tax"] = "1.08" if self[:oysters]["tax"].nil?
		@receiving_times.each do |time|
			self[:oysters][time] = Hash.new if self[:oysters][time].nil?
			@types.each do |type|
				self[:oysters][time][type] = Hash.new if self[:oysters][time][type].nil? 
				@supplier_numbers.each do |number|
					self[:oysters][time][type][number] = Hash.new if self[:oysters][time][type][number].nil?
					if (type == "large") || (type == "small")
						6.times do |i|
							self[:oysters][time][type][number][i.to_s] = 0 if self[:oysters][time][type][number][i.to_s] == nil
						end
					else
						self[:oysters][time][type][number]["0"] = 0 if self[:oysters][time][type][number]["0"] == nil 
					end
					self[:oysters][time][type][number]["subtotal"] = 0 if self[:oysters][time][type][number]["subtotal"].nil?

					self[:oysters][type] = Hash.new if self[:oysters][type].nil? 
					self[:oysters][type][number] = Hash.new if self[:oysters][type][number].nil? 
					self[:oysters][type][number]["volume"] = 0 if self[:oysters][type][number]["volume"].nil? 
					self[:oysters][type][number]["price"] = 0 if self[:oysters][type][number]["price"].nil? 
					self[:oysters][type][number]["invoice"] = 0 if self[:oysters][type][number]["invoice"].nil? 
				end
			end
		end		
		okayama_setup
	end

	def okayama_setup
		# Hinase by size, single daily price
		self[:oysters]["okayama"] = Hash.new if self[:oysters]["okayama"].nil?
		self[:oysters]["okayama"]["hinase"] = Hash.new if self[:oysters]["okayama"]["hinase"].nil?
		["大", "中", "小"].each do |type|
			self[:oysters]["okayama"]["hinase"][type] = 0 if self[:oysters]["okayama"]["hinase"][type].nil?
		end
		self[:oysters]["okayama"]["hinase"]["subtotal"] = 0 if self[:oysters]["okayama"]["hinase"]["subtotal"].nil?
		self[:oysters]["okayama"]["hinase"]["price"] = 0 if self[:oysters]["okayama"]["hinase"]["price"].nil?
		self[:oysters]["okayama"]["hinase"]["invoice"] = 0 if self[:oysters]["okayama"]["hinase"]["invoice"].nil?
		# Iri by supplier number, single daily price
		self[:oysters]["okayama"]["iri"] = Hash.new if self[:oysters]["okayama"]["iri"].nil?
		["1", "2", "7", "15", "38"].each do |num|
			self[:oysters]["okayama"]["iri"][num] = Hash.new if self[:oysters]["okayama"]["iri"][num].nil?
			self[:oysters]["okayama"]["iri"][num]["volume"] = 0 if self[:oysters]["okayama"]["iri"][num]["volume"].nil?
			self[:oysters]["okayama"]["iri"][num]["price"] = 0 if self[:oysters]["okayama"]["iri"][num]["price"].nil?
		end
		self[:oysters]["okayama"]["iri"]["subtotal"] = 0 if self[:oysters]["okayama"]["iri"]["subtotal"].nil?
		self[:oysters]["okayama"]["iri"]["price"] = 0 if self[:oysters]["okayama"]["iri"]["price"].nil?
		self[:oysters]["okayama"]["iri"]["invoice"] = 0 if self[:oysters]["okayama"]["iri"]["invoice"].nil?
		# Tamatsu by supplier number, single daily price
		self[:oysters]["okayama"]["tamatsu"] = Hash.new if self[:oysters]["okayama"]["tamatsu"].nil?
		["1", "2", "4", "5"].each do |num|
			self[:oysters]["okayama"]["tamatsu"][num] = Hash.new if self[:oysters]["okayama"]["tamatsu"][num].nil?
			self[:oysters]["okayama"]["tamatsu"][num]["大"] = 0 if self[:oysters]["okayama"]["tamatsu"][num]["大"].nil?
			self[:oysters]["okayama"]["tamatsu"][num]["小"] = 0 if self[:oysters]["okayama"]["tamatsu"][num]["小"].nil?
			self[:oysters]["okayama"]["tamatsu"][num]["volume"] = 0 if self[:oysters]["okayama"]["tamatsu"][num]["volume"].nil?
			self[:oysters]["okayama"]["tamatsu"][num]["price"] = 0 if self[:oysters]["okayama"]["tamatsu"][num]["price"].nil?
		end
		self[:oysters]["okayama"]["tamatsu"]["small_price"] = 0 if self[:oysters]["okayama"]["tamatsu"]["small_price"].nil?
		self[:oysters]["okayama"]["tamatsu"]["subtotal"] = 0 if self[:oysters]["okayama"]["tamatsu"]["subtotal"].nil?
		self[:oysters]["okayama"]["tamatsu"]["price"] = 0 if self[:oysters]["okayama"]["tamatsu"]["price"].nil?
		self[:oysters]["okayama"]["tamatsu"]["invoice"] = 0 if self[:oysters]["okayama"]["tamatsu"]["invoice"].nil?
		# Mushiage by array of won bid price and volume (non-specified supplier), many daily prices (up to 8)
		self[:oysters]["okayama"]["mushiage"] = Hash.new if self[:oysters]["okayama"]["mushiage"].nil?
		8.times do |t|
			self[:oysters]["okayama"]["mushiage"][t.to_s] = Hash.new if self[:oysters]["okayama"]["mushiage"][t.to_s].nil?
			self[:oysters]["okayama"]["mushiage"][t.to_s]["volume"] = 0 if self[:oysters]["okayama"]["mushiage"][t.to_s]["volume"].nil?
			self[:oysters]["okayama"]["mushiage"][t.to_s]["price"] = 0 if self[:oysters]["okayama"]["mushiage"][t.to_s]["price"].nil?
		end
		self[:oysters]["okayama"]["mushiage"]["subtotal"] = 0 if self[:oysters]["okayama"]["mushiage"]["subtotal"].nil?
		self[:oysters]["okayama"]["mushiage"]["invoice"] = 0 if self[:oysters]["okayama"]["mushiage"]["invoice"].nil?
	end

	def parsed_date
		DateTime.strptime(self.supply_date, "%Y年%m月%d日")
	end

	def year_to_date_range
		#Season starts over (fiscal year) in October
		if self.supply_date
			parsed_date = self.parsed_date
			self_month = parsed_date.month
			if self_month >= 10
				start_year = parsed_date.year
				end_year = (parsed_date + 1.year).year
			else
				start_year = (parsed_date - 1.year).year
				end_year = parsed_date.year
			end
		else
			if Date.today.month.to_i >= 10
				start_year = Date.today.year
				end_year = (Date.today + 1.year).year
			else
				start_year = (Date.today - 1.year).year
				end_year = Date.today.year
			end
		end
		season_start_date = Date.new(start_year, 10, 1)
		season_end_date = Date.new(end_year, 9, 30)
		#From start of season to date of record called
		if self.supply_date
			year_to_date_range = season_start_date..DateTime.strptime(self.supply_date, "%Y年%m月%d日")
		else
			year_to_date_range = season_start_date..season_end_date
		end
		year_to_date_range
	end

	def calculate_new_year_to_date
		set_variables
		#Calculate record
		new_year_to_date = Hash.new
		year_to_date_range.each do |d|
			date = d.strftime('%Y年%m月%d日')
			oyster_supply = OysterSupply.find_by(supply_date: date)
			if !oyster_supply.nil?
				data = oyster_supply.oysters
				@types.each do |type|
					data[type].each do |supplier_id, totals|
						new_year_to_date[supplier_id].nil? ? new_year_to_date[supplier_id] = Hash.new : ()
						new_year_to_date[supplier_id][type].nil? ? new_year_to_date[supplier_id][type] = Hash.new : ()
						if new_year_to_date[supplier_id][type][:price].nil?
							new_year_to_date[supplier_id][type][:price] = Array.new
							(totals["price"] != "0") ? new_year_to_date[supplier_id][type][:price] << totals["price"].to_f : ()
						else
							(totals["price"] != "0") ? new_year_to_date[supplier_id][type][:price] << totals["price"].to_f : ()
						end
						new_year_to_date[supplier_id][type][:volume].nil? ? new_year_to_date[supplier_id][type][:volume] = totals["volume"].to_f : new_year_to_date[supplier_id][type][:volume] += totals["volume"].to_f
						new_year_to_date[supplier_id][type][:invoice].nil? ? new_year_to_date[supplier_id][type][:invoice] = totals["invoice"].to_f : new_year_to_date[supplier_id][type][:invoice] += totals["invoice"].to_f
					end
				end
			end
		end
		new_year_to_date[:updated] = DateTime.now
		new_year_to_date
	end

	def last_oysters_update
		self.oysters_last_update.nil? ? (self.oysters_last_update = self.updated_at) : ()
		self.oysters_last_update
	end

	def year_to_date_update_required?
		year_to_date_range.each do |d|
			oyster_supply = OysterSupply.find_by(supply_date: d.strftime('%Y年%m月%d日'))
			if !oyster_supply.nil? && (oyster_supply.id != self.id)
				if self.oysters[:year_to_date]
					if self.last_oysters_update > self.oysters[:year_to_date][:updated]
						return true
					end
				else
					return true
				end
			end
		end
		return false
	end

	def year_to_date
		if year_to_date_update_required?
			self.oysters[:year_to_date] = calculate_new_year_to_date
			if self.save
				puts "Year to date re-caclulation was required"
			else
				puts "There was an error saving the year to date re-caclulation"
				puts self.errors.messages
			end
		end
		self.oysters[:year_to_date]
	end

	def oyster_data
		set_variables
		oysters = self.oysters
		oyster_data = Hash.new
		locations = ["坂越", "相生"]
		locations.each do |location|
			oyster_data[location] = Hash.new
			oyster_data[location][:total] = 0
		end
		@types.each do |type|
			oysters[type].each do |supplier_id, keys|
				supplier = Supplier.where(:id => supplier_id).first

				oyster_data[supplier.location][type].nil? ? oyster_data[supplier.location][type] = Hash.new : ()
				#list volumes by price
				if oyster_data[supplier.location][type][keys["price"]].nil?
					oyster_data[supplier.location][type][keys["price"]] = keys["volume"].to_f
				else
					oyster_data[supplier.location][type][keys["price"]] += keys["volume"].to_f
				end
				oyster_data[supplier.location][:total] += (keys["price"].to_f * keys["volume"].to_f)
				#volume subtotal by type
				oyster_data[supplier.location][:volume_total].nil? ? oyster_data[supplier.location][:volume_total] = Hash.new : ()
				if oyster_data[supplier.location][:volume_total][type].nil?
					oyster_data[supplier.location][:volume_total][type] = keys["volume"].to_f
				else
					oyster_data[supplier.location][:volume_total][type] += keys["volume"].to_f
				end
				#volume price subtotal by type
				oyster_data[supplier.location][:price_type_total].nil? ? oyster_data[supplier.location][:price_type_total] = Hash.new : ()
				if oyster_data[supplier.location][:price_type_total][type].nil?
					oyster_data[supplier.location][:price_type_total][type] = (keys["price"].to_f * keys["volume"].to_f)
				else
					oyster_data[supplier.location][:price_type_total][type] += (keys["price"].to_f * keys["volume"].to_f)
				end
			end
		end
		locations.each do |location|
			oyster_data[location][:tax] = (oyster_data[location][:total] * 0.08).to_i
			oyster_data[location][:total].to_i
		end
		oyster_data
	end

	def do_payment_pdf
		require "prawn"
		require "open-uri"

		# Set up varibles
		set_variables
		date_range = self.start_date..self.end_date - 1.day
		funabiki_info = {:content => "<b>〒678-0232 </b>
		兵庫県赤穂市1576－11
		(株)船曳商店
		TEL (0791)43-6556 FAX (0791)43-8151
		メール info@funabiki.info", :size => 8}
		if self.location == "sakoshi"
			# Sakoshi Information
			info = {:content => "<b>〒678-0215 </b>
			兵庫県赤穂市御崎1798－1
			赤穂市漁業協同組合
			TEL 0791(45)2260 FAX 0791(45)2261", :size => 8}
			locale = "坂越"
			suppliers = @sakoshi_suppliers
		elsif self.location == "aioi"
			info = {:content => "<b>〒678-0041 </b>
			兵庫県相生市相生３丁目４−２２
			相生漁業協同組合
			TEL  0791(22)0344", :size => 8}
			locale = "相生"
		else
			info = ""
			locale = ""
		end

		# Widdle down the suppliers to only one's for the dates given
		supplier_ids = Set.new
		supplier_dates = Hash.new
		supplies_dates = Array.new
		date_range.each do |d|
			date = d.strftime('%Y年%m月%d日')
			oyster_supply = OysterSupply.find_by(supply_date: date)
			if !oyster_supply.nil?
				supplies_dates << oyster_supply.supply_date
				oysters = oyster_supply.oysters.except(:year_to_date, :updated)
				oysters.each do |time, type|
					if type.is_a?(Hash)
						type.each do |key, values|
							values.each do |id, v|
								if !v["subtotal"].nil?
									if (v["subtotal"] != "0")
										supplier_ids << id.to_i
										supplier_dates[id.to_i].nil? ? supplier_dates[id.to_i] = Set.new : ()
										supplier_dates[id.to_i] << date
									end
								elsif !v["0"].nil?
									if (v["0"] != "0")
										supplier_ids << id.to_i
										supplier_dates[id.to_i].nil? ? supplier_dates[id.to_i] = Set.new : ()
										supplier_dates[id.to_i] << date
									end
								end
							end
						end
					end
				end
			end
		end
		dates_for_print = "（" + supplies_dates.first + " ~ " + supplies_dates.last + "）"
		suppliers = Supplier.where(:id => supplier_ids).where(location: locale).order(:supplier_number)

		# Funabiki Logo
		funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")

		# TOTAL FARMERS OUTPUT
		if self.export_format == "all"
			Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [25], disposition: "inline") do |pdf|
				# document set up
				pdf.font_families.update(PrawnPDF.fonts)
				# set utf-8 japanese font
				pdf.font "SourceHan"
				pdf.font_size 10
				# Set up the table data and header
				table_data = Array.new
				table_data << [info, {:image => funabiki_logo, :scale => 0.065, :position  => :center }, funabiki_info]
				# Title rows
				table_data << [{:content => "<b>（" + locale + "）支払明細書</b>", :colspan => 3, :align => :center, :height => 35, :padding => 0}]
				table_data << [{:content => dates_for_print, :colspan => 3, :size => 8, :padding => 4, :align => :center}]
				table_data << [{:content => "", :colspan => 3, :size => 8, :padding => 2, :align => :center}]
				# Set up daily calculation header
				daily_tables = Array.new
				daily_tables << ["月日", "商品名", "数量", "単位", "単価", "金額", "総合計"]
				daily_tables_header = pdf.make_table(daily_tables, :width => 545, :cell_style => { :border_width => 0 }, :column_widths => {0 => 45, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 110}) do |t|
					t.row(0..-1).size = 9
				end
				# Daily calculations for matching records in the given date range go here
				i = 0
				total_no_tax = 0
				total_tax = 0
				volume_totals = Hash.new
				date_range.each do |d|
					date = d.strftime('%Y年%m月%d日')
					oyster_supply = OysterSupply.find_by(supply_date: date)
					if !oyster_supply.nil?
						data = oyster_supply.oyster_data
						if data[locale][:total] != 0
							total_no_tax += data[locale][:total]
							total_tax += data[locale][:tax]
							daily_data = Array.new
							# Just do the header once
							if i == 0
								daily_data << [{:content => daily_tables_header, :colspan => 7}]
								i += 1
							end
							daily_data_row = Array.new
							#daily_volume_row = Array.new
							# Make subtotal table
								subtotal_table_data = Array.new
								volume_subtotal_table_data = Array.new
								is = 0
								@types.each do |type|
									it = 0
									data[locale][type].each do |price, volume|
										if volume != 0
											subtotal_row = Array.new
											if is == 0
												subtotal_row << d.strftime('%m') + "." + d.strftime('%d') + "（" + weekday_japanese(d.strftime("%w").to_i) + "）"
												is += 1
											else
												subtotal_row << '　'
											end
											subtotal_row << type_to_japanese(type)
											subtotal_row << volume
											subtotal_row << type_to_unit(type)
											subtotal_row << yenify(price)
											subtotal_row << yenify((volume * price.to_f))
											subtotal_row << ""
											subtotal_table_data << subtotal_row
											if it == 0
												volume_subtotal_table_data << ["", {:content => ("―" + type_to_japanese(type) + "小計―"), :align => :right }, { :content => data[locale][:volume_total][type].to_s, :align => :right }, type_to_unit(type), "", yenify(data[locale][:price_type_total][type]), "" ]
												it += 1
											end
										end
									end
									volume_totals[type].nil? ? (volume_totals[type] = Hash.new) : ()
									volume_totals[type][:volume].nil? ? (volume_totals[type][:volume] = data[locale][:volume_total][type]) : (volume_totals[type][:volume] += data[locale][:volume_total][type])
									volume_totals[type][:total].nil? ? (volume_totals[type][:total] = data[locale][:price_type_total][type]) : (volume_totals[type][:total] += data[locale][:price_type_total][type])
								end
								subtotal_table_data << ["", "", "", "", "", { :content => "消費税(8%)", :align => :right }, "" ]
								subtotal_table = pdf.make_table(subtotal_table_data, :position => :center, :width => 544, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 45, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
									t.row(-1).column(-1).content = yenify(data[locale][:tax].to_f)
									t.row(-2).column(-1).content = yenify(data[locale][:total].to_f).to_s
									t.row(-1).column(-1).font_style = :light
									t.row(-2).column(-1).font_style = :bold
									values = t.cells.columns(0..-1).rows(0..-1)
									bad_cells = values.filter do |cell|
										cell.content == "0"
									end
									bad_cells.background_color = "FFAAAA"
								end
								#volume_subtotal_table = pdf.make_table(volume_subtotal_table_data, :position => :center, :width => 544, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
								#
								#end
							daily_data_row << { :content => subtotal_table, :colspan => 7 }
							#daily_volume_row << { :content => volume_subtotal_table, :colspan => 7, :height => 100 }
							daily_data << daily_data_row
							#daily_data << daily_volume_row
							volume_subtotal_table_data.each do |volume_data_row|
								daily_data << volume_data_row
							end
							daily_table = pdf.make_table(daily_data, :position => :center, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 110}) do |t|
								t.row(0).border_top_width = 0.5
								t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]

							end
							table_data << [{:content => daily_table, :colspan => 3}]
						end
					end
				end

				# Volume totals row
				volume_total_table_rows = Array.new
				volume_totals.each do |type, keys|
					if keys[:volume] != 0
						volume_total_table_rows << ["", { :content => ("―" + type_to_japanese(type) + "合計―"), :align => :right}, { :content => keys[:volume].to_s, :align => :right }, type_to_unit(type), "", { :content => yenify(keys[:total]) }, ""]
					end
				end
				if volume_total_table_rows.empty?
					volume_total_table_rows << [{ :content => ("単価は入力されていないです。もう一回確認は必要です。"), :align => :center, :colspan => 7}]
				end
				volume_total_table = pdf.make_table(volume_total_table_rows, :position => :center, :cell_style => { :inline_format => true, :size => 7, :border_width => 0, :padding => 3}, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
					t.row(0).border_top_width = 0.5
					t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]
				end
				# Total row
				total_table_rows = Array.new
				total_table_rows << ["買上金額", "消費税額", "今回支払金額"]
				total_table_rows << [ yenify(total_no_tax), yenify(total_tax), yenify(total_no_tax + total_tax)]
				total_table = pdf.make_table(total_table_rows, :position => :center, :cell_style => { :inline_format => true, :size => 8, :border_width => 0, :align => :center }) do |t|
					t.row(0).font_style = :bold
					t.row(0).border_bottom_width = 1
					t.row(0).border_bottom_width = 1
					t.row(0).border_top_width = 1
					t.row(-1).border_bottom_width = 1
					t.column(0).border_left_width = 1
					t.column(-1).border_right_width = 1
				end
				table_data << [{:content => " ", :colspan => 3, :height => 7}]
				table_data << [{:content => volume_total_table, :colspan => 3}]
				table_data << [{:content => " ", :colspan => 3, :height => 7}]
				table_data << [{:content => total_table, :colspan => 3}]
				table_data << [{:content => " ", :colspan => 3, :height => 7}]

				pdf.table(table_data, :position => :center, :cell_style => { :inline_format => true, :min_font_size => 8 }, :width => 545.28, :column_widths => {0 => 181.76, 1 => 181.76, 2 => 181.76}) do |t|
					t.cells.border_width = 0
						t.row(0).padding = 5
						t.row(0).border_top_width = 2
						t.row(-1).border_bottom_width = 2
						t.column(0).border_left_width = 2
						t.column(-1).border_right_width = 2
						t.row(0).border_bottom_width = 0.15
						t.row(1).column(-1).size = 8
						t.row(1).column(0).size = 12
						t.row(1).padding = 10
						t.row(-3).border_lines = [:dotted, :solid, :solid, :solid]
						t.row(-3).border_top_width = 0.5
					t.before_rendering_page do |page|
						page.row(0).border_top_width = 2
						page.row(-1).border_bottom_width = 2
						page.column(0).border_left_width = 2
						page.column(-1).border_right_width = 2
					end
				end

				pdf.encrypt_document(user_password: self.password,owner_password: self.password) if self.password
				pdf_data = Array.new
				pdf_data << dates_for_print
				pdf_data << pdf
				funabiki_logo.close
				return pdf_data
			end

		# INDIVIDUAL FARMER OUTPUT
		elsif self.export_format == "individual"
			#get the year to date totals ready
			last_date_record = OysterSupply.find_by(supply_date: supplies_dates.last)
			year_to_date_data = last_date_record.year_to_date
			# document set up
			Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [25]) do |pdf|
				# set utf-8 japanese font
				pdf.font_families.update(PrawnPDF.fonts)

				pdf.font "SourceHan"
				pdf.font_size 10

				suppliers.each_with_index do |supplier, i|
					if i != 0
						pdf.start_new_page
					end
					# Set up the table data and header
					table_data = Array.new
					table_data << [info, {:image => funabiki_logo, :scale => 0.065, :position  => :center }, funabiki_info]
					# Title rows
					table_data << [{:content => "<b>〔" + supplier.supplier_number.to_s + "〕 " + supplier.company_name + " ― 支払明細書</b>", :colspan => 3, :align => :center}]
					table_data << [{:content => "（" + supplies_dates.first + " ~ " + supplies_dates.last + "）", :colspan => 3, :size => 8, :padding => 4, :align => :center}]
					table_data << [{:content => "", :colspan => 3, :size => 8, :padding => 2, :align => :center}]
					# Set up daily calculation header
					daily_tables_h_row = Array.new
					daily_tables_h_row << ["月日", "商品名", "数量", "単位", "単価", "金額", "総合計"]
					daily_tables_header = pdf.make_table(daily_tables_h_row, :header => true, :width => 545, :cell_style => { :border_width => 0 }, :column_widths => {0 => 45, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 110}) do |t|
						t.row(0..-1).size = 9
					end

					i = 0
					total_no_tax = 0
					total_tax = 0
					supplier_total = 0
					supplier_type_totals = Hash.new
					supplier_dates[supplier.id].each do |date|
						day_total = 0
						oyster_supply = OysterSupply.find_by(supply_date: date)
						if !oyster_supply.nil?
							data = oyster_supply.oysters
							d = Date.strptime(date, "%Y年%m月%d日")
							gapi = d.strftime('%m').to_s + "." + d.strftime('%d').to_s + "（" + weekday_japanese(d.strftime("%w").to_i).to_s + "）"
							daily_data = Array.new
							# Just do the header once
							if i == 0
								daily_data << [{:content => daily_tables_header, :colspan => 7}]
								i += 1
							end
							it = 0
							@types.each do |type|
								volume = data[type][supplier.id.to_s]["volume"]
								price = data[type][supplier.id.to_s]["price"]
								subtotal = yenify((volume.to_f * price.to_f))
								if volume != "0"
									if it == 0
										daily_data << [gapi, type_to_japanese(type), volume, type_to_unit(type), yenify(price), subtotal, "" ]
										it += 1
									else
										daily_data << ["", type_to_japanese(type), volume, type_to_unit(type), yenify(price), subtotal, "" ]
									end
								end
								day_total += (volume.to_f * price.to_f)
								total_no_tax += (volume.to_f * price.to_f)
								total_tax += ((volume.to_f * price.to_f) * 0.08)
								supplier_total += (volume.to_f * price.to_f)
								supplier_type_totals[type].nil? ? supplier_type_totals[type] = Hash.new : ()
								supplier_type_totals[type][:volume].nil? ? supplier_type_totals[type][:volume] = volume.to_f : supplier_type_totals[type][:volume] += volume.to_f
								supplier_type_totals[type][:total].nil? ? supplier_type_totals[type][:total] = (volume.to_f * price.to_f) : supplier_type_totals[type][:total] += (volume.to_f * price.to_f)
							end
							daily_data << ["", "", "", "", "", { :content => "消費税(8%)", :align => :right }, "" ]
							daily_table = pdf.make_table(daily_data, :position => :center, :width => 545, :cell_style => { :border_width => 0, :size => 7, :padding => 3 }, :column_widths => {0 => 50, 1 => 160, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 105}) do |t|
								t.row(0).border_top_width = 0.5
								t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]
								t.rows(0..-1).size = 8
								t.row(-1).column(-1).content = yenify(day_total)
								t.row(-1).column(-1).font_style = :bold
								t.row(-2).column(-1).content = yenify(day_total)
								t.row(-2).column(-1).font_style = :bold
								t.row(-1).column(-1).content = yenify_with_decimal(day_total * 0.08)
								t.row(-1).column(-1).font_style = :light
								values = t.cells.columns(0..-1).rows(0..-1)
								bad_cells = values.filter do |cell|
									cell.content == "0"
								end
								bad_cells.background_color = "FFAAAA"
							end
							table_data << [{:content => daily_table, :colspan => 3}]
						end
					end

					# Volume totals row
					volume_total_table_rows = Array.new
					supplier_type_totals.each do |type, keys|
						if keys[:volume] != 0
							volume_total_table_rows << ["", { :content => ("―" + type_to_japanese(type) + "合計―"), :align => :right}, { :content => keys[:volume].to_s, :align => :right }, type_to_unit(type), "", { :content => yenify(keys[:total].to_s) }, ""]
						end
					end
					volume_total_table = pdf.make_table(volume_total_table_rows, :position => :center, :cell_style => { :inline_format => true, :size => 7, :border_width => 0, :padding => 3}, :column_widths => {0 => 35, 1 => 170, 2 => 45, 3 => 45, 4 => 70, 5 => 70, 6 => 109}) do |t|
						t.row(0).border_top_width = 0.5
						t.row(0).border_lines = [:dotted,:dotted,:dotted,:dotted]
					end

					# Total row
					total_table_rows = Array.new
					total_table_rows << ["買上金額", "消費税額", "今回支払金額"]
					total_table_rows << [ yenify(total_no_tax), yenify(total_tax), yenify(total_no_tax + total_tax)]
					total_table = pdf.make_table(total_table_rows, :header => true, :position => :center, :cell_style => { :inline_format => true, :size => 8, :border_width => 0, :height => 18, :align => :center }) do |t|
						t.row(0).font_style = :bold
						t.row(0).border_bottom_width = 1
						t.row(0).border_bottom_width = 1
						t.row(0).border_top_width = 1
						t.row(-1).border_bottom_width = 1
						t.column(0).border_left_width = 1
						t.column(-1).border_right_width = 1
					end

					table_data << [{:content => " ", :colspan => 3, :height => 7}]
					table_data << [{:content => volume_total_table, :colspan => 3}]
					table_data << [{:content => " ", :colspan => 3, :height => 7}]
					table_data << [{:content => total_table, :colspan => 3}]
					table_data << [{:content => " ", :colspan => 3, :height => 7}]

					pdf.table(table_data, :position => :center, :header => true, :cell_style => { :inline_format => true, :min_font_size => 8 }, :width => 545.28, :column_widths => {0 => 181.76, 1 => 181.76, 2 => 181.76}) do |t|
						t.cells.border_width = 0
						t.before_rendering_page do |page|
							page.row(0).padding = 5
							page.row(0).border_top_width = 2
							page.row(-1).border_bottom_width = 2
							page.column(0).border_left_width = 2
							page.column(-1).border_right_width = 2
							page.row(0).border_bottom_width = 0.15
							page.row(1).column(-1).size = 8
							page.row(1).column(0).size = 12
							page.row(1).padding = 10
							page.row(1).height = 50
							t.row(-3).border_lines = [:dotted, :solid, :solid, :solid]
							t.row(-3).border_top_width = 0.5
						end
					end

					# Year to date calculations by supplier
					pdf.move_down 10
					yearly = year_to_date_data[supplier.id.to_s]
					yearly_data = Array.new
					yearly_data << [{:content => "今シーズンの総合計算", :colspan => (@types.size + 1)}]
					type_row = Array.new
					price_row = Array.new
					invoice_row = Array.new
					volume_row = Array.new
					@types.each_with_index do |type, i|
						if i == 0
							type_row << " "
							price_row << "平均単価"
							invoice_row << "合計金額"
							volume_row << "計量合計"
						end
						price_average = (yearly[type][:price].inject{ |sum, el| sum + el }.to_f / yearly[type][:price].size)
						price_average.nan? ? price_average = "0" : price_average
						type_row << type_to_japanese(type)
						price_row << yenify(price_average.to_f.round(0))
						invoice_row << yenify(yearly[type][:invoice])
						volume_row << yearly[type][:volume].to_s
					end
					yearly_data << type_row
					yearly_data << volume_row
					yearly_data << price_row
					yearly_data << invoice_row
					pdf.table(yearly_data, :position => :center, :width => 545.28, :cell_style => { :inline_format => true, :size => 7, :align => :center, :border_width => 0.25 }) do |t|
						t.row(0).size = 10
						t.row(0).font_style =:bold
						t.row(0).border_top_width = 1
						t.row(-1).border_bottom_width = 1
						t.column(0).border_left_width = 1
						t.column(-1).border_right_width = 1
					end

				end

				pdf.encrypt_document(user_password: self.password,owner_password: self.password) if self.password
				pdf_data = Array.new
				pdf_data << dates_for_print
				pdf_data << pdf
				funabiki_logo.close
				return pdf_data
			end
		else
			#do nothing, unexpected param is bad.
		end
	end

	def generate_supply_check
		set_variables
		am_or_pm = ["午前", "午後"]
		funabiki_info = {:content => "<b>〒678-0232 </b>
		兵庫県赤穂市1576－11
		(株)船曳商店
		TEL (0791)43-6556 FAX (0791)43-8151
		メール info@funabiki.info", :size => 8, :padding => 3, :colspan => 3}
		funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")
		logo_cell = {:image => funabiki_logo, :scale => 0.065, :colspan => 4, :position  => :center }
		created_info = {:content => '<b><font size="12">作成日・更新日</font></b>
		2019年05月31日
		2019年04月02日', :size => 10, :padding => 3, :colspan => 3, :align => :right}
		darker = 'cfcfcf'
		guidelines = '〇＝適切　X＝不適切
		不適切な場合は備考欄に日付と説明を
		書いてください。'
		require "prawn"
		require "open-uri"
		Prawn::Document.generate("PDF.pdf", :page_size => "A4", :margin => [15]) do |pdf|
			# document set up
			pdf.font_families.update(PrawnPDF.fonts)
			# set utf-8 japanese font
			pdf.font "SourceHan"
			pdf.font_size 10
			am_or_pm.each_with_index do |am_or_pm, i|
				if i != 0
					pdf.start_new_page
				end
				table_data = Array.new
				table_data << [{:content => guidelines, :colspan => 3, :rowspan => 3, :size => 9, :align => :center, :valign => :center}, {:content => "(マガキ)生牡蠣原料受入表①（兵庫県産）", :colspan => 5, :rowspan => 3, :size => 14, :padding => 7, :align => :center, :valign => :center, :font_style => :bold}, {:content => "確認日付", :colspan => 2, :size => 7, :padding => 1, :align => :left, :valign => :center}]
				table_data << ["社長", "品管"]
				table_data << [" <br> ", " <br> "]
				table_data << [{:content => "", :colspan => 10, :padding => 3}]
				table_data << [ {:content => self.supply_date, :colspan => 5, :size => 10, :align => :center}, {:content => am_or_pm, :colspan => 2, :size => 10, :align => :center}, {:content => "時刻:", :colspan => 3, :size => 10, :align => :left}]
				table_data << ["海域", "生産者", "数量(㎏)", "セル数", "官能検査", "温度(℃)", "pH", "塩分(%)", "最終判定", "確認者"]
				suppliers = [@sakoshi_suppliers, @aioi_suppliers]
				suppliers.each do |area_suppliers|
					large_total = 0
					small_total = 0
					area_suppliers.each do |s|
						large_total += self.oysters.dig(kanji_am_pm(am_or_pm), "large", s.id.to_s, "subtotal").to_f
						small_total += self.oysters.dig(kanji_am_pm(am_or_pm), "small", s.id.to_s, "subtotal").to_f
					end
					area_suppliers.each_with_index do |supplier, i|
						large_subtotal = self.oysters.dig(kanji_am_pm(am_or_pm), "large", supplier.id.to_s, "subtotal").to_f
						small_subtotal = self.oysters.dig(kanji_am_pm(am_or_pm), "small", supplier.id.to_s, "subtotal").to_f
						large_shell_subtotal = self.oysters.dig(kanji_am_pm(am_or_pm), "large_shells", supplier.id.to_s, "0").to_i
						small_shell_subtotal = self.oysters.dig(kanji_am_pm(am_or_pm), "small_shells", supplier.id.to_s, "0").to_i
						thin_shell_subtotal = self.oysters.dig(kanji_am_pm(am_or_pm), "thin_shells", supplier.id.to_s, "0").to_i
						darken = (large_subtotal + small_subtotal + large_shell_subtotal + small_shell_subtotal + thin_shell_subtotal).zero?
						supplier_top_row = Array.new
						if i == 0
							supplier_top_row << { :content => supplier.location[0] + "<br>" + supplier.location[1] + "<font size='11'><br><br>大<br>" + large_total.to_s + "<br><br>小<br>" + small_total.to_s + "</font>", :rowspan => (area_suppliers.length * 2), :size => 28, :valign => :center, :align => :center}
						end
						#set up totals for shucked oysters
						supplier_top_row << { :content => number_to_circular(supplier.supplier_number.to_s), :size => 12, :align => :center, background_color: (darken ? darker : 'ffffff')}
						supplier_total = (self.oysters.dig(kanji_am_pm(am_or_pm), "large", supplier.id.to_s, "subtotal").to_f + self.oysters.dig(kanji_am_pm(am_or_pm), "small", supplier.id.to_s, "subtotal").to_f + self.oysters.dig(kanji_am_pm(am_or_pm), "eggy", supplier.id.to_s, "subtotal").to_f).to_s
						#set up totals for shells
						shells = Array.new
						shells << (self.oysters.dig(kanji_am_pm(am_or_pm), "large_shells", supplier.id.to_s, "0").to_i + self.oysters.dig(kanji_am_pm(am_or_pm), "small_shells", supplier.id.to_s, "0").to_i).to_s
						shells << self.oysters.dig(kanji_am_pm(am_or_pm), "thin_shells", supplier.id.to_s, "0")
						supplier_top_row.push({:content => '<font size="7">合計   </font><b>' + (darken ? 'なし' : supplier_total) + "<b>", :size => 10}, {:content => (darken ? 'なし' : (shells.join("個／") + "㎏")), size: 7, :align => :center}, "", {:content => "℃", :align => :right, :size => 7}, "", {:content => "%", :align => :right, :size => 7}, "", "")
						supplier_buckets = Array.new
						bucket_types = ["large", "small", "eggy"]
						bucket_types.each do |type|
							6.times do |i|
								this_bucket = self.oysters.dig(kanji_am_pm(am_or_pm), type, supplier.id.to_s, i.to_s).to_s
								supplier_buckets << this_bucket
							end
						end
						supplier_buckets.reject! {|x| x == "0" || x == ""}
						supplier_bottom_row = [{ :content => supplier.company_name, :size => 7, :align => :center, :padding => 2, background_color: (darken ? darker : 'ffffff') }, { :content => supplier_buckets.join("　　") + " ", :colspan => 6, :size => 8, :font_style => :light}, { :content => ":数量小計/備考", :colspan => 1, :size => 6, :padding => 2, :align => :right, valign: :center}, '']
						table_data << supplier_top_row
						table_data << supplier_bottom_row
					end
				end
				guidelines_one = "●記録の頻度
					入荷ごとに海域および生産者別に行う。
					●備考欄に生産者の牡蠣の質・状態についての一言を記入する、または 最終判定が×の場合、その理由と措置を記入する
					●判定基準
					漁獲場所、むき身の量、生産者の名前または記録番号を記載するタグを確認する"
				guidelines_two = "●判定基準（続き）
					官能検査：見た目で異常がなく、異臭等が無いこと。
					品温：０～20℃
					ｐH：6.0～8.0
					塩分：0.5％以上
					最終判定：上記項目およびその他に異常がなく、原料として受け入れられるもの。"
				table_data << [{:content => "", :colspan => 10, :padding => 3}]
				table_data << [{:content => guidelines_one, :colspan => 5, :padding => 5, :size => 8}, {:content => guidelines_two, :colspan => 5, :padding => 5, :size => 8}]
				table_data << [{:content => "", :colspan => 10, :padding => 15}]
				table_data << [funabiki_info, logo_cell, created_info]
				pdf.table(table_data, :position => :center, :cell_style => { :inline_format => true, :border_width => 0 }, :width => pdf.bounds.width, :column_widths => {0..9 => (pdf.bounds.width / 10)} ) do |t|
					t.row(3).size = 12
					t.rows(3..4).font_style = :bold
					t.rows(0..2).columns(0..-1).border_width = 0.25
					t.row(-3).border_width = 0.25
					t.rows(4..5).border_width = 0.25
					t.rows(6..((@sakoshi_suppliers.length + @aioi_suppliers.length)* 2) + 5).columns(-1).border_right_width = 0.25
					t.row(((@sakoshi_suppliers.length + @aioi_suppliers.length)* 2) + 5).border_bottom_width = 0.25
					t.cells.rows(5..((@sakoshi_suppliers.length + @aioi_suppliers.length)* 2) + 5).columns(0..8).style do |c|
						( ((c.row % 2).zero?) && (c.column != 1) && (c.column != 2) ) ? (c.border_width = 0.25) : ()
						( (!(c.row % 2).zero?) && (c.column == 1) ) ? (c.border_right_width = 0.25 && c.border_bottom_width = 0.25) : ()
						( ((c.row % 2).zero?) && (c.column == 2) ) ? (c.border_left_width = 0.25) : ()
						( (!(c.row % 2).zero?) && (c.column == 2) ) ? (c.border_bottom_width = 0.25) : ()
						(c.column == 8) ? c.border_right_width = 0.25 : ()
						if c.background_color == darker
							t.rows(c.row).columns(2..8).background_color = darker
						end
					end
					t.row(5 + (@sakoshi_suppliers.length * 2)).column(-1).border_bottom_width = 0.25
				end
			end
			funabiki_logo.close
			return pdf
		end
	end

end
