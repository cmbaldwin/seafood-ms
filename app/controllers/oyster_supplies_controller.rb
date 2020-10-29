class OysterSuppliesController < ApplicationController
	before_action :set_oyster_supply, only: [:show, :edit, :update, :destroy, :supply_check]
	before_action :check_status
	before_action :set_info, except: [:fetch_invoice, :fetch_supplies, :index]

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

	# GET /oyster_supplies/new_invoice/:start_date/:end_date
	def new_invoice
		@invoice = OysterInvoice.new(
			start_date: params[:start_date],
			end_date: params[:end_date],
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
		export_format = params[:format]
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
end
