class OysterInvoicesController < ApplicationController
	before_action :set_oyster_invoice, only: [:show, :edit, :update, :destroy]

	# GET /oyster_invoices
	# GET /oyster_invoices.json
	def index
		@oyster_invoices = OysterInvoice.search(params[:id]).paginate(:page => params[:page], :per_page => 8)
	end

	def new
		redirect_to oyster_supplies_path
	end

	def edit
		redirect_to oyster_supplies_path
	end

	# GET /oyster_invoices/1
	# GET /oyster_invoices/1.json
	def show
		redirect_to oyster_invoice_search_path(params[:id])
	end

	# POST /oyster_invoices
	# POST /oyster_invoices.json
	def create
		invoice = OysterInvoice.new(
			start_date: oyster_invoice_params[:start_date],
			end_date: oyster_invoice_params[:end_date],
			aioi_emails: oyster_invoice_params[:aioi_emails],
			sakoshi_emails: oyster_invoice_params[:sakoshi_emails],
			data: {
				passwords: {
					"sakoshi_all_password" => SecureRandom.hex(4).to_s,
					"sakoshi_seperated_password" => SecureRandom.hex(4).to_s,
					"aioi_all_password" => SecureRandom.hex(4).to_s,
					"aioi_seperated_password" => SecureRandom.hex(4).to_s},
				processing: true,
				},
			completed: ((oyster_invoice_params[:completed] == "0") ? false : true),
			send_at: oyster_invoice_params[:send_at]
			)
		invoice.oyster_supply_ids = invoice.date_range.map { |date| (supply = OysterSupply.find_by(supply_date: (date.strftime('%Y年%m月%d日')))) ? (supply.id) : () }
		if invoice.save
			message = Message.new(user: current_user.id, model: 'oyster_invoice', state: false, message: '牡蠣原料仕切り作成中…', data: {invoice_id: invoice.id})
			message.save
			if ProcessInvoiceWorker.perform_async(invoice.id, current_user.id, message.id)
				redirect_to oyster_invoice_search_path(invoice.id), notice: "仕切りは処理中です。しばらくお待ちください。"
			else
				redirect_to oyster_invoice_search_path(invoice.id), notice: "仕切りのエラーが発生しました。アドミニストレータに確認してください。"
			end
		else
			respond_to do |format|
				format.html { redirect_to oyster_supplies_path, notice: invoice.errors.full_messages.each { |msg| msg + "\n" } }
				format.json { render json: invoice.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /oyster_invoices/1
	# PATCH/PUT /oyster_invoices/1.json
	def update
		respond_to do |format|
			if @oyster_invoice.update(oyster_invoice_params)
				format.html { redirect_to @oyster_invoice, notice: '仕切りを更新しました。' }
				format.json { render :show, status: :ok, location: @oyster_invoice }
			else
				format.html { render :show }
				format.json { render json: @oyster_invoice.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /oyster_invoices/1
	# DELETE /oyster_invoices/1.json
	def destroy
		@oyster_invoice.destroy
		respond_to do |format|
			format.html { redirect_to oyster_invoices_path, notice: '仕切りを削除しました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_oyster_invoice
			@oyster_invoice = OysterInvoice.find(params[:id])
		end

		# Only allow a list of trusted parameters through.
		def oyster_invoice_params
			params.require(:oyster_invoice).permit(:start_date, :end_date, :aioi_all_pdf, :aioi_seperated_pdf, :sakoshi_all_pdf, :sakoshi_seperated_pdf, :completed, :aioi_emails, :sakoshi_emails, :data, :send_at)
		end
end
