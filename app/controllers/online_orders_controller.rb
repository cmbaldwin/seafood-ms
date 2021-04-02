class OnlineOrdersController < ApplicationController
	before_action :set_online_order, only: %i[ destroy ]

	def fetch_online_orders_list
		fetch_list_params[:date] ? @search_date = Date.parse(fetch_list_params[:date]) : @search_date = Date.today
		@daily_orders = OnlineOrder.all.where(ship_date: @search_date).order(:order_time)
		@daily_orders += OnlineOrder.where(ship_date: nil).order(:order_time) if @search_date == Date.today
	end

	# GET /online_orders or /online_orders.json
	def index
		fetch_online_orders_list
		@online_orders = OnlineOrder.where(ship_date: (params[:start]..params[:end]))
		@online_orders += OnlineOrder.where(ship_date: nil) if @search_date = Date.today
	end

	def refresh
		WCAPI.new.update
		redirect_to action: "index"
	end

	def online_orders_shipping_list
		ship_date = online_order_generator_params[:ship_date]
		@filename = "FunabikiInfo 出荷表（#{ship_date}）.pdf"
		message = Message.new(user: current_user.id, model: 'online_orders_shipping_list', state: false, message: "Funabiki.info出荷表を作成中…", data: {ship_date: ship_date, filename: @filename, expiration: (DateTime.now + 1.day)})
		message.save
		OnlineOrdersShippingListWorker.perform_async(ship_date, message.id, @filename)
	end

	# DELETE /online_orders/1 or /online_orders/1.json
	def destroy
		@online_order.destroy
		respond_to do |format|
			format.html { redirect_to online_orders_url, notice: "Online order was successfully destroyed." }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_online_order
			@online_order = OnlineOrder.find(params[:id])
		end

		def online_order_generator_params
			params.permit(:ship_date)
		end

		def fetch_list_params
			params.permit(:date, :_, :start, :end, :format)
		end

		# Only allow a list of trusted parameters through.
		def online_order_params
			params.require(:online_order).permit(:order_id, :status, :ship_date, :arrival_date, :order_date, :date_modified, :data)
		end
end
