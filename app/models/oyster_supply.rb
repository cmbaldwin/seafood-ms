class OysterSupply < ApplicationRecord
	has_one :oyster_invoices_supply
	has_one :oyster_invoice, through: :oyster_invoices_supply, validate: false

	before_save :set_totals

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

	def previous
		self.oyster_supply_query.previous
	end

	def next
		self.oyster_supply_query.next
	end

	def date
		DateTime.strptime(self.supply_date, "%Y年%m月%d日")
	end

	def locked?
		!self.oyster_invoice.nil?
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
		japanese = {"large" => "kg", "small" => "kg", "eggy" => "kg", "large_shells" => "個", "small_shells" => "個", "thin_shells" => "kg"}
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

	def okayama_total
		total = 0
		["hinase", "tamatsu", "iri", "mushiage"].each do |location|
			total += self.oysters["okayama"][location]["subtotal"].to_f unless self.oysters["okayama"].nil?
		end
		total
	end

	def shucked_subtotals
		@volume_subtotals = Hash.new
		@cost_subtotals = Hash.new
		['large', 'small', 'eggy'].each do |type|
			@volume_subtotals[type] = Hash.new if @volume_subtotals[type].nil?
			@cost_subtotals[type] = Hash.new if @cost_subtotals[type].nil?
			self.oysters[type].each do |supplier, amounts|
				location = Supplier.find(supplier).location
				@volume_subtotals[type][location].nil? ? @volume_subtotals[type][location] = amounts["volume"].to_f : @volume_subtotals[type][location] += amounts["volume"].to_f
				@cost_subtotals[type][location].nil? ? @cost_subtotals[type][location] = amounts["invoice"].to_f : @cost_subtotals[type][location] += amounts["invoice"].to_f
			end
		end
	end

	def hyogo_large_shucked_total
		total = 0
		self.oysters['large'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def hyogo_small_shucked_total
		total = 0
		self.oysters['small'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def hyogo_small_shucked_eggy_total
		total = 0
		self.oysters['eggy'].each do |supplier, amounts|
			total += amounts["volume"].to_f
		end
		total
	end

	def mukimi_total
		hyogo_large_shucked_total + hyogo_small_shucked_total + hyogo_small_shucked_eggy_total + okayama_total
	end

	def hyogo_thin_shells_total
		total = 0
		self.oysters['thin_shells'].each do |supplier, amounts|
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
		hyogo_mukimi_cost_total + okayama_mukimi_cost_total
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

	def hyogo_mukimi_cost_total
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
			shucked_subtotals
			totals = Hash.new
			totals[:okayama_total] = okayama_total
			totals[:shell_total] = shells_total
			totals[:big_shell_avg_cost] = big_shell_avg_cost
			totals[:sakoshi_eggy_volume] = @volume_subtotals["eggy"]["坂越"]
			totals[:sakoshi_small_volume] = @volume_subtotals["small"]["坂越"]
			totals[:sakoshi_large_volume] = @volume_subtotals["large"]["坂越"]
			totals[:sakoshi_muki_volume] = totals[:sakoshi_eggy_volume] + totals[:sakoshi_small_volume] + totals[:sakoshi_large_volume]
			totals[:aioi_eggy_volume] = @volume_subtotals["eggy"]["相生"]
			totals[:aioi_small_volume] = @volume_subtotals["small"]["相生"]
			totals[:aioi_large_volume] = @volume_subtotals["large"]["相生"]
			totals[:aioi_muki_volume] = totals[:aioi_eggy_volume] + totals[:aioi_small_volume] + totals[:aioi_large_volume]
			totals[:sakoshi_eggy_cost] = @cost_subtotals["eggy"]["坂越"]
			totals[:sakoshi_small_cost] = @cost_subtotals["small"]["坂越"]
			totals[:sakoshi_large_cost] = @cost_subtotals["large"]["坂越"]
			totals[:sakoshi_muki_cost] = totals[:sakoshi_eggy_cost] + totals[:sakoshi_small_cost] + totals[:sakoshi_large_cost]
			totals[:sakoshi_avg_kilo] = (totals[:sakoshi_muki_volume] == 0) ? 0.0 : (totals[:sakoshi_muki_cost] / totals[:sakoshi_muki_volume])
			totals[:aioi_eggy_cost] = @cost_subtotals["eggy"]["相生"]
			totals[:aioi_small_cost] = @cost_subtotals["small"]["相生"]
			totals[:aioi_large_cost] = @cost_subtotals["large"]["相生"]
			totals[:aioi_muki_cost] = totals[:aioi_eggy_cost] + totals[:aioi_small_cost] + totals[:aioi_large_cost]
			totals[:aioi_avg_kilo] = (totals[:aioi_muki_volume] == 0) ? 0.0 : (totals[:aioi_muki_cost] / totals[:aioi_muki_volume])
			totals[:hyogo_total] = hyogo_large_shucked_total + hyogo_small_shucked_total + hyogo_small_shucked_eggy_total
			totals[:hyogo_mukimi_cost_total] = hyogo_mukimi_cost_total
			totals[:hyogo_avg_kilo] = (totals[:hyogo_total] == 0) ? 0.0 : (totals[:hyogo_mukimi_cost_total] / totals[:hyogo_total])
			totals[:okayama_mukimi_cost_total] = okayama_mukimi_cost_total
			totals[:okayama_avg_kilo] = ((totals[:okayama_total] == 0) ? 0.0 : (totals[:okayama_mukimi_cost_total] / totals[:okayama_total]))
			totals[:mukimi_total] = totals[:hyogo_total] + okayama_total
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
		if self.oysters[:okayama]["hinase"]["subtotal"].to_i > 0
			((completion["okayama"] << "hinase") if self.oysters[:okayama]["hinase"]["price"].to_s == "0") if self.oysters[:okayama]["hinase"]["subtotal"].to_s != "0"
		end
		if self.oysters[:okayama]["iri"]["subtotal"].to_i > 0
			((completion["okayama"] << "iri") if self.oysters[:okayama]["iri"]["price"].to_s == "0" ) if self.oysters[:okayama]["iri"]["subtotal"].to_s != "0"
		end
		if self.oysters[:okayama]["tamatsu"]["subtotal"].to_i > 0
			self.oysters[:okayama]["tamatsu"].each do |sup_num, sup_hash|
				if sup_hash.is_a?(Hash)
					if (sup_hash["小"] != "0") || (sup_hash["小"] != "0")
						(completion["okayama"].to_s << "tamatsu") if sup_hash["price"].to_s == "0"
					end
				end
			end
		end
		if self.oysters[:okayama]["mushiage"]["subtotal"].to_i > 0
			self.oysters[:okayama]["mushiage"].each do |sup_num, sup_hash|
				if sup_hash.is_a?(Hash)
					if sup_hash["volume"].to_s != "0"
						(completion["okayama"].to_s << "mushiage") if sup_hash["price"].to_s == "0"
					end
				end
			end
		end
		completion.delete('okayama') if (!completion["okayama"].nil? && completion["okayama"].empty?)
		completion
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

end
