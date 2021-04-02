class WelcomeController < ApplicationController
	include RManifestsHelper
	include ManifestsHelper

	def index

	end

	def profit_figures_chart
		if current_user.admin?
			# Set up graphs for seasonal profit to date
			time_setup

				# Set up the yearly chart with two recent seasons of data
				# https://ankane.github.io/chartkick.js/examples/
				@year_sales = Hash.new
				@last_year_sales = Hash.new
				# Consider swithc to Profit.where("sales_date like ?", "%2020%") in the future
				# Or do a migration with a date to date string
				Profit.all.order(:sales_date).each do |profit|
					unless profit.totals[:profits].nil?
						date = profit.sales_date_to_datetime.strftime("%m月%d日")
						if profit.sales_date_to_datetime > @this_season_start && profit.sales_date_to_datetime < @this_season_end
							@year_sales[date] = 0 if @year_sales[date].nil?
							@year_sales[date] += (profit.totals[:profits] <= 0 ? 0 : (profit.totals[:profits] / 10000))
						elsif profit.sales_date_to_datetime > @prior_season_start && profit.sales_date_to_datetime < @prior_season_end
							@last_year_sales[date] = 0 if @last_year_sales[date].nil?
							@last_year_sales[date] += (profit.totals[:profits] <= 0 ? 0 : (profit.totals[:profits] / 10000))
						end
					end
				end

				ymax = @year_sales.merge(@last_year_sales).values.max
				ymax.nil? ? (@yearly_max = ymax.round(-(ymax.to_i.to_s.length - 4))) : (@yearly_max = 0)

				#Not used right now, but could be used
				unless @year_sales.empty? || @last_year_sales.empty?
					@this_year_daily_average = '万￥' + helpers.yenify(@year_sales.values.sum / @year_sales.values.length)
					@last_year_daily_average = '万￥' + helpers.yenify(@last_year_sales.values.sum / @last_year_sales.values.length)
					@two_year_daily_average = '万￥' + helpers.yenify(@year_sales.merge(@last_year_sales).values.sum / @year_sales.merge(@last_year_sales).values.length)
				end

			@data_array = [{name: @this_season_start.year.to_s + ' ~ ' + @this_season_end.year.to_s, data: @year_sales},
						{name: @prior_season_start.year.to_s + ' ~ ' + @prior_season_end.year.to_s, data: @last_year_sales},
				]
		else
			@data_array = [{name: 'Unauthorized', data: {}}]
		end
		render json: @data_array
	end

	def kilo_sales_estimate_chart
		if current_user.admin?
			# Set up graphs for seasonal profit to date
			time_setup
			@this_year_est = Hash.new
			@last_year_est = Hash.new
			query_array = (@prior_season_start.year..@this_season_end.year).map{|yr| "%#{yr.to_s}%" }
			Profit.where("sales_date ILIKE ANY ( array[?] )", query_array).order(:sales_date).each do |profit|
				unless profit.totals[:profits].nil?
					date = profit.sales_date_to_datetime.strftime("%m月%d日")
					volumes = profit.volumes
					kilo_price = (profit.totals[:profits] / (volumes[:total_volume] / 1000)).round(0)
					if profit.sales_date_to_datetime > @this_season_start && profit.sales_date_to_datetime < @this_season_end
						if @this_year_est[date].nil?
							@this_year_est[date] = kilo_price
						else
							@this_year_est[date] = kilo_price if (kilo_price.to_i < @this_year_est[date].to_i)
						end
					elsif profit.sales_date_to_datetime > @prior_season_start && profit.sales_date_to_datetime < @prior_season_end
						if @last_year_est[date].nil?
							@last_year_est[date] = kilo_price
						else
							@last_year_est[date] = kilo_price if (kilo_price.to_i < @last_year_est[date].to_i)
						end
					end
				end
			end
			@last_year_est.each{|date, val| @this_year_est[date] = 0 if @this_year_est[date].nil?}
			@data_array = [{name: @this_season_start.year.to_s + ' ~ ' + @this_season_end.year.to_s, data: @this_year_est.sort.to_h},
						{name: @prior_season_start.year.to_s + ' ~ ' + @prior_season_end.year.to_s, data: @last_year_est.sort.to_h},
				]
		else
			@data_array = [{name: 'Unauthorized', data: {}}]
		end
		render json: @data_array
	end

	def recent_oyster_supplies
		query_array = (@prior_season_start.year..@this_season_end.year).map{|yr| "%#{yr.to_s}%" }
		OysterSupply.where("supply_date ILIKE ANY ( array[?] )", query_array)
	end

	def farmer_kilo_costs_chart
		if current_user.admin?
			# Set up graphs for seasonal profit to date
			time_setup
			@this_year_costs = Hash.new
			@last_year_costs = Hash.new
			recent_oyster_supplies.order(:supply_date).each do |supply|
				unless supply.oysters.empty?
					date = supply.date.strftime("%m月%d日")
					kilo_price = supply.totals[:cost_total]
					volume = supply.totals[:mukimi_total]
					unless kilo_price == 0 || volume == 0
						kilo_price = (kilo_price / volume).round(0)
					else
						kilo_price = 0
					end
					if supply.date > @prior_season_start && supply.date < @prior_season_end
						@last_year_costs[date] = kilo_price
						@this_year_costs[date] = 0 if @this_year_costs[date].nil?
					elsif supply.date > @this_season_start && supply.date < @this_season_end
						@this_year_costs[date] = kilo_price
						@last_year_costs[date] = 0 if @last_year_costs[date].nil?
					end
				end
			end
			@this_year_costs.sort.to_h
			@data_array = [{name: @this_season_start.year.to_s + ' ~ ' + @this_season_end.year.to_s, data: @this_year_costs.sort.to_h},
						{name: @prior_season_start.year.to_s + ' ~ ' + @prior_season_end.year.to_s, data: @last_year_costs.sort.to_h},
				]
		else
			@data_array = [{name: 'Unauthorized', data: {}}]
		end
		render json: @data_array
	end

	def daily_volumes_chart
		if current_user.admin?
			# Set up graphs for seasonal profit to date
			time_setup
			@this_year_volume = Hash.new
			@last_year_volume = Hash.new
			recent_oyster_supplies.order(:supply_date).each do |supply|
				unless supply.oysters.empty?
					date = supply.date.strftime("%m月%d日")
					volume = supply.totals[:mukimi_total]
					if supply.date > @this_season_start && supply.date < @this_season_end
						@this_year_volume[date] = volume
						@last_year_volume[date] = 0 if @last_year_volume[date].nil?
					elsif supply.date > @prior_season_start && supply.date < @prior_season_end
						@last_year_volume[date] = volume
						@this_year_volume[date] = 0 if @this_year_volume[date].nil?
					end
				end
			end
			@data_array = [{name: @this_season_start.year.to_s + ' ~ ' + @this_season_end.year.to_s, data: @this_year_volume.sort.to_h},
						{name: @prior_season_start.year.to_s + ' ~ ' + @prior_season_end.year.to_s, data: @last_year_volume.sort.to_h},
				]
		else
			@data_array = [{name: 'Unauthorized', data: {}}]
		end
		render json: @data_array
	end

	def noshi_modal

		render partial: "noshi_modal"
	end

	def yahoo_orders_partial
		time_setup
		@yahoo_orders = YahooOrder.all.where(ship_date: Date.today)
		@yahoo_date = DateTime.now
		@new_yahoo_orders = YahooOrder.where(ship_date: nil).order(:order_id).map{ |order| order unless order.order_status(false) == 4}.compact
		(@new_yahoo_orders.length > 0) ? () : (@new_yahoo_orders = nil)

		render partial: "yahoo_orders"
	end

	def new_yahoo_orders_modal
		time_setup
		@yahoo_orders = YahooOrder.all.where(ship_date: Date.today)
		@yahoo_date = DateTime.now
		@new_yahoo_orders = YahooOrder.where(ship_date: nil).order(:order_id).map{ |order| order unless order.order_status(false) == 4}.compact
		(@new_yahoo_orders.length > 0) ? () : (@new_yahoo_orders = nil)

		render partial: "new_yahoo_orders_modal"
	end

	def receipt_partial
		rakuten_today = RManifest.where(:sales_date => @today).first
		if rakuten_today != nil
			@rakuten = rakuten_today
		else
			@rakuten = RManifest.last
		end

		render partial: 'receipt'
	end

	def rakuten_shinki_modal
		# Check for new and unprocessed orders from rakuten
		rakuten_check
		time_setup

		render partial: "rakuten_shinki_modal"
	end

	def rakuten_orders
		time_setup
		rakuten_today = RManifest.where(:sales_date => @today).first
		if rakuten_today != nil
			@rakuten = rakuten_today
		else
			@rakuten = RManifest.last
		end
		# Check for new and unprocessed orders from rakuten
		rakuten_check

		render partial: "rakuten_orders"
	end

	def front_online_orders
		@search_date = Date.today
		@daily_orders = OnlineOrder.where(ship_date: @search_date)
		@new_online_orders = OnlineOrder.where(ship_date: nil, status: 'processing')

		render partial: "online_orders"
	end

	def online_orders_modal
		@new_online_orders = OnlineOrder.where(ship_date: nil, status: 'processing')

		render partial: "online_orders_modal"
	end

	def front_infomart_orders
		@date = Date.today
		@infomart_orders = InfomartOrder.where(ship_date: @date)

		@infomart_shinki = InfomartOrder.where(ship_date: nil, status: "発注済")

		render partial: "infomart_orders"
	end

	def infomart_shinki_modal
		@infomart_shinki = InfomartOrder.where(ship_date: nil, status: "発注済")

		render partial: "infomart_shinki_modal"
	end

	def daily_expiration_cards
		time_setup
		expiration_card_links_setup

		render partial: "daily_expiration_cards"
	end

	def expiration_card_links_setup

		# Set up the shelled oyster expiration cards
		source_sakoshi = "兵庫県坂越海域"
		source_aioi = "兵庫県相生海域"

		ExpirationCard.preload(:download)

		@sakoshi_expiration_today = ExpirationCard.where(ingredient_source: source_sakoshi,  manufactuered_date: nengapi_maker(Date.today, 0), expiration_date: nengapi_maker(Date.today, 4), made_on: true, shomiorhi: true).first
		@sakoshi_expiration_today_five = ExpirationCard.where(ingredient_source: source_sakoshi,  manufactuered_date: nengapi_maker(Date.today, 0), expiration_date: nengapi_maker(Date.today, 5), made_on: true, shomiorhi: true).first
		@sakoshi_expiration_tomorrow = ExpirationCard.where(ingredient_source: source_sakoshi,  manufactuered_date: nengapi_maker(Date.today, 1), expiration_date: nengapi_maker(Date.today, 5), made_on: true, shomiorhi: true).first
		@sakoshi_expiration_tomorrow_five = ExpirationCard.where(ingredient_source: source_sakoshi,  manufactuered_date: nengapi_maker(Date.today, 1), expiration_date: nengapi_maker(Date.today, 6), made_on: true, shomiorhi: true).first
		@sakoshi_expiration_today_five_expo = ExpirationCard.where(ingredient_source: source_sakoshi,  manufactuered_date: nengapi_maker(Date.today, 0), expiration_date: nengapi_maker(Date.today, 5), made_on: false, shomiorhi: true).first
		@sakoshi_expiration_muji = ExpirationCard.where(ingredient_source: source_sakoshi,  manufactuered_date: '', expiration_date: '', made_on: true).first
		@sakoshi_expiration_frozen = ExpirationCard.where(product_name: "冷凍殻付き牡蠣（プロトン凍結）", ingredient_source: source_sakoshi).first

		@aioi_expiration_today = ExpirationCard.where(ingredient_source: source_aioi,  manufactuered_date: nengapi_maker(Date.today, 0), expiration_date: nengapi_maker(Date.today, 4), made_on: true, shomiorhi: true).first
		@aioi_expiration_today_five = ExpirationCard.where(ingredient_source: source_aioi,  manufactuered_date: nengapi_maker(Date.today, 0), expiration_date: nengapi_maker(Date.today, 5), made_on: true, shomiorhi: true).first
		@aioi_expiration_tomorrow = ExpirationCard.where(ingredient_source: source_aioi,  manufactuered_date: nengapi_maker(Date.today, 1), expiration_date: nengapi_maker(Date.today, 5), made_on: true, shomiorhi: true).first
		@aioi_expiration_tomorrow_five = ExpirationCard.where(ingredient_source: source_aioi,  manufactuered_date: nengapi_maker(Date.today, 1), expiration_date: nengapi_maker(Date.today, 6), made_on: true, shomiorhi: true).first
		@aioi_expiration_today_five_expo = ExpirationCard.where(ingredient_source: source_aioi,  manufactuered_date: nengapi_maker(Date.today, 0), expiration_date: nengapi_maker(Date.today, 5), made_on: false, shomiorhi: true).first
		@aioi_expiration_muji = ExpirationCard.where(ingredient_source: source_aioi,  manufactuered_date: '', expiration_date: '', made_on: true).first
	end

	def insert_receipt_data
		@rakuten = RManifest.find(params[:rakuten])
		@order_id = params[:order_id]
		@order = @rakuten.new_orders_hash.reverse[@order_id.to_i]
		@purchaser = @order[:sender]['familyName']
		@oysis = params[:oysis]
		@sales_date = params[:sales_date] || to_nengapi(DateTime.now)
		@amount = @order[:final_cost].to_s
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_rakuten_order
		time_setup
		@rakuten = RManifest.find(params[:id])
		@noshi = Noshi.new
		rakuten_today = RManifest.where(:sales_date => @today).first
		if rakuten_today
			@rakuten.sales_date == (rakuten_today.sales_date) ? rakuten_check : ()
		end
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_online_orders
		@new_online_orders = OnlineOrder.where(ship_date: nil, status: 'processing')
		@search_date = Date.parse(params[:date])
		@daily_orders = OnlineOrder.where(ship_date: @search_date)

		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_yahoo_orders
		@yahoo_date = Date.parse(params[:date])
		@yahoo_orders = YahooOrder.all.where(ship_date: @yahoo_date)
		(@yahoo_date == Date.today) ? (@new_yahoo_orders = YahooOrder.where(ship_date: nil).order(:order_id).map{ |order| order unless order.order_status(false) == 4}.compact) : ()
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_infomart_orders
		@date = Date.parse(params[:date])
		@infomart_orders = InfomartOrder.all.where(ship_date: @date)
		@infomart_shinki = InfomartOrder.where(ship_date: nil, status: "発注済")

		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def weather_partial
		# Return a observational data at the present time
		weatherb = Weatherb::API.new(ENV['CLIMACELL_API'])
		@weather = weatherb.realtime(lat: 34.733552, lon: 134.377873)

		render partial: "weather"
	end

	def printables

		render partial:  "printables"
	end

	def user_control
		@users = User.all

		render partial: "usercontrol"
	end

	def charts_partial

		render partial: "charts"
	end

	def frozen_data_setup
		time_setup

		@frozen_products = Product.where(product_type: '冷凍')
		@frozen_oyster = FrozenOyster.all.order(:manufacture_date, :ampm).reverse.first

		@frozen_shucked_season = Hash.new
		@frozen_shelled_season = Hash.new
		@frozen_totals = Hash.new
		FrozenOyster.where(manufacture_date: ((@this_season_start..@this_season_end).map{|d| d.strftime('%Y年%m月%d日')})).order(:manufacture_date).each do |frozen_data|
			frozen_data.finished_packs.each do |product, value|
				@frozen_totals[product].nil? ? (@frozen_totals[product] = value.to_f) : (@frozen_totals[product] += value.to_f)
			end
			@frozen_shucked_season[frozen_data.manufacture_date_to_datetime.strftime("%m月%d日")] = frozen_data.stats[:finished_packs_total]
			@frozen_shelled_season[frozen_data.manufacture_date_to_datetime.strftime("%m月%d日")] = (frozen_data.stats[:finished_shells_total] * 100)
		end
	end

	def frozen_data
		frozen_data_setup

		render partial: "frozen_data"
	end

	def frozen_data_modal
		frozen_data_setup
		
		render partial: 'frozen_data_modal'
	end

	def shipping_data_csv
		require 'csv'

		new_data = [%w(配送事業者コード 配送伝票番号 納品日 送料)]
		original_data = []
		dates = Set.new
		if csv_params[:csv]
			CSV.foreach(csv_params[:csv], encoding: 'Shift_JIS:UTF-8').with_index do |row, i|
				unless i == 0
					date = DateTime.strptime(row[3], "%m月%d日")
					new_data << [10, row[4], date.strftime("%Y/%m/%d"), row[11]]
					dates << date
					original_data << row.map{|ci| ci.to_s} #fix for encoding issue
				end
			end
		end
		dates = dates.sort.to_a
		start_date = dates[0]
		end_date = dates[-1]

		local_data = CSVWriter.new.collect_online_shop_data(start_date, end_date)
		local_nums = local_data.map{|r| r[6]}
		yamato_numbers = new_data.map{|r| r[1].remove('-')}
		local_nums_fixed = local_nums.map{|n| n.include?(',') ? n.split(',') : n }.flatten
		local_nums_fixed2 = local_nums_fixed.map{|n| n.include?('、') ? n.split('、') : n }.flatten
		local = local_nums_fixed2.map{|n| (n.length != 12) ? "3#{n}" : n }
		error_arr = []
		yamato_numbers.each{|yb| error_arr << yb unless (local.include?(yb) || yb.length < 12)}
		error_data = []
		original_data.each do |row|
			error_data << row if error_arr.include?(row[4].remove('-'))
		end

		config = {
			encoding: "Shift_JIS",
			headers: true
		}
		hanbai_csv = CSV.generate(config) do |csv|
			local_data.each do |array|
				if yamato_numbers.include?(array[6])
					csv << array
				end
			end
		end
		shipped_csv = CSV.generate(config) do |csv|
			new_data.each do |array|
				csv << array
			end
		end
		error_csv = CSV.generate(config) do |csv|
			error_data.each do |array|
				csv << array
			end
		end

		if params[:format] == "販売実績"
			to_send = hanbai_csv
		elsif params[:format] == "発送実績"
			to_send = shipped_csv
		else
			to_send = error_csv
		end

		send_data(to_send, 
			type: 'text/csv; charset=UTF-8; header=present', 
			filename: "#{params[:format]}（#{start_date.to_s(:number)}_#{end_date.to_s(:number)}）.csv", 
			disposition: :attachment)
	end

	private

		def csv_params
			params.permit(:csv, :commit, :format, :authenticity_token)
		end

end
