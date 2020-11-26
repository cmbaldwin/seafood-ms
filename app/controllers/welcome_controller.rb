class WelcomeController < ApplicationController
	include RManifestsHelper
	include ManifestsHelper

	def index
		# Setup Users for the user control panel
		@users = User.all
		time_setup

		# Temporarily removed
		# frozen_data_setup

		rakuten_orders

		# Return a observational data at the present time
		weatherb = Weatherb::API.new(ENV['CLIMACELL_API'])
		@weather = weatherb.realtime(lat: 34.733552, lon: 134.377873)
		
	end

	def frozen_data_setup
		@frozen_products = Product.where(product_type: '冷凍')
		@frozen_oyster = FrozenOyster.all.order(:manufacture_date, :ampm).reverse.first

		@frozen_shucked_season = Hash.new
		@frozen_shelled_season = Hash.new
		@frozen_totals = Hash.new
		FrozenOyster.all.order(:manufacture_date).each do |frozen_data|
			frozen_data.finished_packs.each do |product, value|
				@frozen_totals[product].nil? ? (@frozen_totals[product] = value.to_f) : (@frozen_totals[product] += value.to_f)
			end
			@frozen_shucked_season[frozen_data.manufacture_date_to_datetime.strftime("%m月%d日")] = frozen_data.stats[:finished_packs_total]
			@frozen_shelled_season[frozen_data.manufacture_date_to_datetime.strftime("%m月%d日")] = (frozen_data.stats[:finished_shells_total] * 100)
		end
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

			@data_array = [{name: '今年', data: @year_sales}, 
						{name: '去年', data: @last_year_sales}, 
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
			Profit.all.order(:sales_date).each do |profit|
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
			@data_array = [{name: @this_season_start.year.to_s + ' ~ ' + @this_season_end.year.to_s, data: @this_year_est}, 
						{name: @prior_season_start.year.to_s + ' ~ ' + @prior_season_end.year.to_s, data: @last_year_est}, 
				]
		else
			@data_array = [{name: 'Unauthorized', data: {}}]
		end
		render json: @data_array
	end

	def farmer_kilo_costs_chart
		if current_user.admin?
			# Set up graphs for seasonal profit to date
			time_setup
			@this_year_costs = Hash.new
			@last_year_costs = Hash.new
			OysterSupply.all.order(:supply_date).each do |supply|
				unless supply.oysters.empty?
					date = supply.date.strftime("%m月%d日")
					kilo_price = supply.totals[:cost_total]
					volume = supply.totals[:mukimi_total]
					unless kilo_price == 0 || volume == 0
						kilo_price = (kilo_price / volume).round(0)
					else
						kilo_price = 0
					end
					if supply.date > @this_season_start && supply.date < @this_season_end
						@this_year_costs[date] = kilo_price
					elsif supply.date > @prior_season_start && supply.date < @prior_season_end
						@last_year_costs[date] = kilo_price
					end
				end
			end
			@data_array = [{name: '今年', data: @this_year_costs}, 
						{name: '去年', data: @last_year_costs}, 
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
			OysterSupply.all.order(:supply_date).each do |supply|
				unless supply.oysters.empty?
					date = supply.date.strftime("%m月%d日")
					volume = supply.totals[:mukimi_total]
					if supply.date > @this_season_start && supply.date < @this_season_end
						@this_year_volume[date] = volume
					elsif supply.date > @prior_season_start && supply.date < @prior_season_end
						@last_year_volume[date] = volume
					end
				end
			end
			@data_array = [{name: '今年', data: @this_year_volume}, 
						{name: '去年', data: @last_year_volume}, 
				]
		else
			@data_array = [{name: 'Unauthorized', data: {}}]
		end
		render json: @data_array
	end

	def yahoo_orders_partial
		time_setup
		@yahoo_orders = YahooOrder.all.where(ship_date: Date.today)
		@yahoo_date = DateTime.now
		@new_yahoo_orders = YahooOrder.where(ship_date: nil).order(:order_id).map{ |order| order unless order.order_status(false) == 4}.compact
		(@new_yahoo_orders.length > 0) ? () : (@new_yahoo_orders = nil)

		render partial: "yahoo_orders"
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
	end

	def online_orders
		time_setup
		tsuhan_today = Manifest.where(:sales_date => @today).first
		if tsuhan_today != nil
			@online_orders = tsuhan_today
		else
			@online_orders = Manifest.last
		end
		wc_check

		render partial: "online_orders"
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
		@sales_date = params[:sales_date]
		@amount = @order[:final_cost].to_s
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_rakuten_order
		time_setup
		@rakuten = RManifest.find(params[:id])
		rakuten_today = RManifest.where(:sales_date => @today).first
		if rakuten_today
			@rakuten.sales_date == (rakuten_today.sales_date) ? rakuten_check : ()
		end
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_online_order
		time_setup
		@online_orders = Manifest.find(params[:id])
		online_today = Manifest.where(:sales_date => @today).first
		if online_today
			@online_orders.sales_date == (online_today.sales_date) ? wc_check : ()
		end
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

end