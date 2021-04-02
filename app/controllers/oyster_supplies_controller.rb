class OysterSuppliesController < ApplicationController
	before_action :set_oyster_supply, only: [:show, :edit, :tippy_stats, :update, :destroy, :supply_check]
	before_action :check_status
	before_action :set_info, only: [:show, :edit, :new_by, :update, :destroy, :supply_check, :supply_price_actions]
	before_action :set_action_params, only: [:supply_action_nav, :supply_previews_actions, :supply_invoice_actions, :supply_price_actions, :supply_stats, :tippy_stats]

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user? || current_user.employee?
		flash.now[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	def set_info
		@sakoshi_suppliers = Supplier.where(location: '坂越').order(:supplier_number)
		@aioi_suppliers = Supplier.where(location: '相生').order(:supplier_number)
		@all_suppliers = @sakoshi_suppliers + @aioi_suppliers
		@receiving_times = ["am", "pm"]
		@types = ["large", "small", "eggy", "large_shells", "small_shells", "thin_shells"]
		@supplier_numbers = @sakoshi_suppliers.pluck(:id).map(&:to_s)
		@supplier_numbers += @aioi_suppliers.pluck(:id).map(&:to_s)
	end

	def location_to_locale(location)
		locale_hash = {"sakoshi" => "坂越", "aioi" => "相生", "oku" => "邑久", "iri" => "伊里", "hinase" => "日生"}
		locale_hash[location]
	end

	def oyster_supply_set
		if @oyster_supply.nil?
			@oyster_supply = OysterSupply.new
			@oyster_supply.do_setup
		end
	end

	# GET /oyster_supplies/fetch_invoice/:id
	def fetch_invoice
		@invoice = OysterInvoice.find(params[:id])

		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def set_action_params
		@start_date = params[:start_date]
		@end_date = params[:end_date]

	end

	def supply_action_nav
		invoice_setup(@start_date, @end_date)
	end

	def supply_previews_actions
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def supply_invoice_actions
		invoice_setup(@start_date, @end_date)

		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def supply_price_actions
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	# POST set_prices/:start_date/:end_date
	def set_prices
		@start_date = set_price_params[:start_date]
		@end_date = set_price_params[:end_date]
		dates = (DateTime.parse(@start_date)..DateTime.parse(@end_date)).map{|d| d.strftime('%Y年%m月%d日')}
		supplies = OysterSupply.where(supply_date: dates)
		prices = set_price_params[:prices]
		@altered = Hash.new
		supplies.each do |supply|
			new_hash = supply.oysters
			prices.each do |prefecture, price_set_hash|
				if prefecture == 'hyogo'
					price_set_hash.each do |index, price_hash|
						unless price_hash['ids'].reject{|id| id.empty? }.empty?
							price_hash['prices'].each do |type, price|
								unless price.empty?
									price_hash['ids'].each do |supplier_id|
										unless supplier_id.empty?
											unless supply.oysters[type][supplier_id]["volume"].to_i.zero?
												new_hash[type][supplier_id]["price"] = price

												@altered[supply.id] = Hash.new unless @altered[supply.id].is_a?(Hash)
												@altered[supply.id]["hyogo"] = Hash.new unless @altered[supply.id]["hyogo"].is_a?(Hash)
												@altered[supply.id]["hyogo"][type] = Hash.new unless @altered[supply.id]["hyogo"][type].is_a?(Hash)
												@altered[supply.id]["hyogo"][type][price] = Array.new unless @altered[supply.id]["hyogo"][type][price].is_a?(Array)
												@altered[supply.id]["hyogo"][type][price] << supplier_id
											end
										end
									end
								end
							end
						end
					end
				elsif prefecture == "okayama"
					if (supply.oysters["okayama"]["hinase"]["subtotal"].to_i > 0) && (price_set_hash["hinase"].to_i > 0)
						new_hash["okayama"]["hinase"]["price"] = price_set_hash["hinase"]

						@altered[supply.id] = Hash.new unless @altered[supply.id].is_a?(Hash)
						@altered[supply.id]["okayama"] = Hash.new unless @altered[supply.id]["okayama"].is_a?(Hash)
						@altered[supply.id]["okayama"]["hinase"] = price_set_hash["hinase"]
					end
					if (supply.oysters["okayama"]["iri"]["subtotal"].to_i > 0) && (price_set_hash["iri"].to_i > 0)
						new_hash["okayama"]["iri"].each do |k, vh|
							vh["price"] = price_set_hash["iri"] if vh["price"]
						end
						new_hash["okayama"]["iri"]["price"] = price_set_hash["iri"]

						@altered[supply.id] = Hash.new unless @altered[supply.id].is_a?(Hash)
						@altered[supply.id]["okayama"] = Hash.new unless @altered[supply.id]["okayama"].is_a?(Hash)
						@altered[supply.id]["okayama"]["iri"] = price_set_hash["iri"]
					end
					if (supply.oysters["okayama"]["tamatsu"]["subtotal"].to_i > 0) && (price_set_hash["tamatsu"]["large"].to_i > 0)
						new_hash["okayama"]["tamatsu"].each do |k, vh|
							vh["price"] = price_set_hash["tamatsu"]["large"] if vh["price"]
						end
						new_hash["okayama"]["tamatsu"]["price"] = price_set_hash["tamatsu"]["large"]

						@altered[supply.id] = Hash.new unless @altered[supply.id].is_a?(Hash)
						@altered[supply.id]["okayama"] = Hash.new unless @altered[supply.id]["okayama"].is_a?(Hash)
						@altered[supply.id]["okayama"]["tamatsu"] = Hash.new unless @altered[supply.id]["okayama"]["tamatsu"].is_a?(Hash)
						@altered[supply.id]["okayama"]["tamatsu"]["large"] = price_set_hash["tamatsu"]["large"]
					end
					if (supply.oysters["okayama"]["tamatsu"]["subtotal"].to_i > 0) && (price_set_hash["tamatsu"]["small"].to_i > 0)
						new_hash["okayama"]["tamatsu"]["small_price"] = price_set_hash["tamatsu"]["small"]

						@altered[supply.id] = Hash.new unless @altered[supply.id].is_a?(Hash)
						@altered[supply.id]["okayama"] = Hash.new unless @altered[supply.id]["okayama"].is_a?(Hash)
						@altered[supply.id]["okayama"]["tamatsu"] = Hash.new unless @altered[supply.id]["okayama"]["tamatsu"].is_a?(Hash)
						@altered[supply.id]["okayama"]["tamatsu"]["small"] = price_set_hash["tamatsu"]["small"]
					end
				end
			end
			supply.oysters = new_hash
			supply.save
		end
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def supply_stats
		@start_date = DateTime.parse(set_price_params[:start_date])
		@end_date = DateTime.parse(set_price_params[:end_date]) - 1.day
		dates = (@start_date..@end_date).map{ |d| d.strftime('%Y年%m月%d日') }
		@supplies = OysterSupply.where(supply_date: dates)
		@profits = Profit.where(sales_date: dates)
		@rakuten_orders = RManifest.where(sales_date: dates)
		
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def tippy_stats
		@stat = params[:stat]
		last_year_three_day_period = [to_nengapi(@oyster_supply.date - 1.year), to_nengapi(@oyster_supply.date - 1.year - 1.day), to_nengapi(@oyster_supply.date - 1.year - 2.days)]

		@previous_supply = @oyster_supply.previous
		@two_previous_supply = @previous_supply.previous if @previous_supply
		@ly_supply = OysterSupply.where(supply_date: last_year_three_day_period).first
		@ly_next_supply = @ly_supply.next if @ly_supply
		@ly_prev_supply = @ly_supply.previous if @ly_supply

		respond_to do |format|
			format.html { render layout: false }
		end
	end

	def invoice_setup(start_date, end_date)
		@invoice = OysterInvoice.new(
			start_date: start_date,
			end_date: end_date,
			aioi_emails: ENV['AIOI_EMAILS'],
			sakoshi_emails: ENV['SAKOSHI_EMAILS'],
			data: {
				passwords: {
					"sakoshi_all_password" => SecureRandom.hex(4).to_s,
					"sakoshi_seperated_password" => SecureRandom.hex(4).to_s,
					"aioi_all_password" => SecureRandom.hex(4).to_s,
					"aioi_seperated_password" => SecureRandom.hex(4).to_s} },
			completed: false
			)
	end

	def new_invoice
		invoice_setup(params[:start_date], params[:end_date])
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	# GET /fetch_supplies
	# GET /fetch_supplies.js
	def fetch_supplies
		supply_start_date = calendar_params["start"] ? (Date.strptime(calendar_params["start"].to_s, '%Y-%m-%d').strftime("%Y年%m月%d日")) : ((Date.today.at_beginning_of_month - 14.days).strftime(""))
		supply_end_date = calendar_params["end"] ? (Date.strptime(calendar_params["end"].to_s, '%Y-%m-%d').strftime("%Y年%m月%d日")) : ((Date.today.end_of_month + 14.days).strftime(""))
		invoice_start_date = calendar_params["start"] ? ((Date.strptime(calendar_params["start"].to_s, '%Y-%m-%d') - 14.days).strftime("%Y-%m-%d")) : ((Date.today.at_beginning_of_month - 14.days).strftime(""))
		invoice_end_date = calendar_params["end"] ? ((Date.strptime(calendar_params["end"].to_s, '%Y-%m-%d') + 14.days).strftime("%Y-%m-%d")) : ((Date.today.end_of_month + 14.days).strftime(""))
		@oyster_supply = OysterSupply.where(:supply_date => supply_start_date..supply_end_date)
		@oyster_invoices = OysterInvoice.where(:start_date => invoice_start_date..invoice_end_date)
	end

	# GET /oyster_supplies
	# GET /oyster_supplies.json
	def index
		fetch_supplies
		@invoice = OysterInvoice.new
		@place = calendar_params[:place]
	end

	def supply_check
		@filename = '原料チェック表（' + @oyster_supply.supply_date + '）.pdf'
		message = Message.new(user: current_user.id, model: 'oyster_supply', state: false, message: '牡蠣原料受入れチェック表を作成中…', data: {oyster_supply_id: @oyster_supply.id, filename: @filename, expiration: (DateTime.now + 1.day)})
		message.save
		OysterSupplyCheckWorker.perform_async(@oyster_supply.id, message.id)
	end

	# GET /oyster_supplies/payment_pdf/:format/:start_date/:end_date/:location
	def payment_pdf
		start_date = Date.parse(params[:start_date])
		end_date = Date.parse(params[:end_date])
		location = params[:location]
		export_format = params[:export_format]
		message = Message.new(user: current_user.id, model: 'oyster_invoice', state: false, message: '牡蠣原料仕切りプレビュー作成中…', data: {invoice_id: 0, expiration: (DateTime.now + 1.day), invoice_preview: {start_date: start_date, end_date: end_date, location: location, export_format: export_format}})
		message.save
		InvoicePreviewWorker.perform_async(start_date, end_date, location, export_format, current_user.id, message.id)
	end

	# GET /oyster_supplies/1
	# GET /oyster_supplies/1.json
	def show
	end

	# GET /oyster_supplies/1/edit
	def edit
	end

	def new
		@oyster_supply = OysterSupply.new
	end

	# GET /oyster_supplies/new
	def new_by
		if new_by_params[:supply_date]
			supply_date = Date.parse(new_by_params[:supply_date]).strftime('%Y年%m月%d日')
		else
			supply_date = nil
		end
		if !supply_date.nil?
			if !OysterSupply.where(:supply_date => supply_date).first.nil?
				@oyster_supply = OysterSupply.where(:supply_date => supply_date).first
				redirect_to oyster_supply_path(@oyster_supply), notice: '牡蠣原料を編集しています。'
			else
				oyster_supply_set
				@oyster_supply.supply_date = supply_date
				flash.now[:notice] = ('新しい原料表を作っています。' + '<br>' + supply_date).html_safe
			end
		else
			oyster_supply_set
		end
	end

	# POST /oyster_supplies
	# POST /oyster_supplies.json
	def create
		@oyster_supply = OysterSupply.new(oyster_supply_params)
		@oyster_supply[:oysters_last_update] = DateTime.now
		respond_to do |format|
			if @oyster_supply.save
				format.html { redirect_to @oyster_supply, notice: '牡蠣原料を更新しました' }
				format.json { render :show, status: :created, location: @oyster_supply }
			else
				format.html { render :new, notice: @oyster_supply.errors }
				format.json { render json: @oyster_supply.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /oyster_supplies/1
	# PATCH/PUT /oyster_supplies/1.json
	def update
		(oyster_supply_params[:oysters] != @oyster_supply.oysters) ? (@oyster_supply[:oysters_last_update] = DateTime.now) :()
		@oyster_supply.set_totals
		respond_to do |format|
			if @oyster_supply.update(oyster_supply_params)
				format.html { redirect_to @oyster_supply, notice: '牡蠣原料を更新しました' }
				format.json { render :show, status: :ok, location: @oyster_supply }
			else
				format.html { render :edit }
				format.json { render json: @oyster_supply.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /oyster_supplies/1
	# DELETE /oyster_supplies/1.json
	def destroy
		@oyster_supply.destroy
		respond_to do |format|
			format.html { redirect_to oyster_supplies_url, notice: '牡蠣原料を削除しました' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_oyster_supply
			@oyster_supply = OysterSupply.find(params[:id])
			@oyster_supply.okayama_setup if @oyster_supply.oysters["okayama"].nil? #in case we're viewing a pre-okayama supply
		end

		def oyster_supply_action_params
			params.permit(:start_date, :end_date)
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def oyster_supply_params
			params.require(:oyster_supply).permit(:supply_date, :oyster_invoice, :oyster_invoice_id, oysters: {})
		end

		def new_by_params
			params.permit(:supply_date)
		end

		def calendar_params
			params.permit(:place, :start, :end, :_, :format)
		end

		def set_price_params
			params.permit(:authenticity_token, :start_date, :end_date, :commit, prices: {} )
		end
end
