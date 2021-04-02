class InfomartOrdersController < ApplicationController
	before_action :set_infomart_order, only: [:show, :edit, :update, :destroy]

	def fetch_infomart_list
		fetch_list_params[:date] ? @search_date = Date.parse(fetch_list_params[:date]) : @search_date = Date.today
		@daily_orders = InfomartOrder.all.where(ship_date: @search_date).order(:order_time)
		@daily_orders += InfomartOrder.where(ship_date: nil).order(:order_time) if @search_date == Date.today
	end

	# GET /infomart_orders
	# GET /infomart_orders.json
	def index
		fetch_infomart_list
		@infomart_orders = InfomartOrder.where(ship_date: (params[:start]..params[:end]))
		@infomart_orders += InfomartOrder.where(ship_date: nil) if @search_date = Date.today
	end

	def refresh
		InfomartAPI.new.acquire_new_data
		redirect_to action: "index"
	end

	def infomart_shipping_list
		ship_date = infomart_generator_params[:ship_date]
		@filename = "Infomart出荷表（#{ship_date}）.pdf"
		message = Message.new(user: current_user.id, model: 'infomart_shipping_list', state: false, message: "Infomart出荷表を作成中…", data: {ship_date: ship_date, filename: @filename, expiration: (DateTime.now + 1.day)})
		message.save
		InfomartShippingListWorker.perform_async(ship_date, message.id, @filename, infomart_generator_params[:include_online])
	end

	# DELETE /infomart_orders/1
	# DELETE /infomart_orders/1.json
	def destroy
		@infomart_order.destroy
		respond_to do |format|
			format.html { redirect_to infomart_orders_url, notice: 'Infomartデータを削除しました.' } 
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_infomart_order
			@infomart_order = InfomartOrder.find(params[:id])
		end

		def infomart_generator_params
			params.permit(:ship_date, :include_online)
		end

		def fetch_list_params
			params.permit(:date, :_, :start, :end, :format)
		end

		# Only allow a list of trusted parameters through.
		def infomart_order_params
			# For the timing being orders can only be modified through the InfomartAPI system, so no need to allow params here.
			# params.require(:infomart_order).permit(:order_id, :status, :order_time, :ship_date, :arrival_date, :address, items: {}, csv_data: {})
		end
end
