class WelcomeController < ApplicationController
	include RManifestsHelper
	include ManifestsHelper

	def index
		# Setup Users for the user control panel
		@users = User.all
		time_setup

		# Setup @today's order lists (initial)
		rakuten_today = RManifest.where(:sales_date => @today).first
		tsuhan_today = Manifest.where(:sales_date => @today).first
		if rakuten_today != nil
			@rakuten = rakuten_today
		else
			@rakuten = RManifest.last
		end
		if tsuhan_today != nil
			@online_orders = tsuhan_today
		else
			@online_orders = Manifest.last
		end

		expiration_card_links_setup

		frozen_data_setup

		infographics_setup

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

	def infographics_setup
		# Set up the yearly chart with two recent seasons of data
		@year_sales = Hash.new
		@last_year_sales = Hash.new
		Profit.all.order(:sales_date).each do |profit|
			if profit.sales_date_to_datetime > @this_season_start && profit.sales_date_to_datetime < @this_season_end
				if !profit.totals[:profits].nil?
					@year_sales[profit.sales_date_to_datetime.strftime("%m月%d日")] = (profit.totals[:profits] <= 0 ? 0 : profit.totals[:profits])
				end
			elsif profit.sales_date_to_datetime > @prior_season_start && profit.sales_date_to_datetime < @prior_season_end
				if !profit.totals[:profits].nil?
					@last_year_sales[profit.sales_date_to_datetime.strftime("%m月%d日")] = (profit.totals[:profits] <= 0 ? 0 : profit.totals[:profits])
				end
			end
		end 

		ymax = @year_sales.merge(@last_year_sales).values.max
		@yearly_max = ymax.round(-(ymax.to_i.to_s.length - 4))
		@this_year_daily_average = '￥' + helpers.yenify(@year_sales.values.sum / @year_sales.values.length)
		@last_year_daily_average = '￥' + helpers.yenify(@last_year_sales.values.sum / @last_year_sales.values.length)
		@two_year_daily_average = '￥' + helpers.yenify(@year_sales.merge(@last_year_sales).values.sum / @year_sales.merge(@last_year_sales).values.length)
	end

	def expiration_card_links_setup
		def nengapi_maker(date, plus)
			(date + plus).strftime('%Y年%m月%d日')
		end

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
		@rakuten = RManifest.find(params[:id])
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def load_online_order
		@online_orders = Manifest.find(params[:id])
		respond_to do |format|
			format.js { render layout: false }
		end
	end

end