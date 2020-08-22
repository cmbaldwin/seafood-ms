class YahooOrdersController < ApplicationController
	before_action :set_yahoo_order, only: [:show, :edit, :update, :destroy]
	before_action :check_status, only: [:yahoo_login, :yahoo_response_auth_code]

	def check_status
		return unless !current_user.approved? || current_user.user? || current_user.employee?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end


	# GET /fetch_yahoo_list/fetch_daily_orders/:date
	# GET /fetch_yahoo_list/fetch_daily_orders.js
	def fetch_yahoo_list
		params[:date] ? @search_date = Date.parse(params[:date]) : @search_date = Date.today
		@daily_orders = YahooOrder.all.where(ship_date: @search_date).order(:order_id)
		@daily_orders += YahooOrder.where(ship_date: nil).order(:order_id) if @search_date == Date.today
	end

	# GET /yahoo_orders
	# GET /yahoo_orders.json
	def index
		fetch_yahoo_list
		@yahoo_orders = YahooOrder.all.where(ship_date: (params[:start]..params[:end]))
		@new_orders = YahooOrder.where(ship_date: nil).order(:order_id)
	end

	def refresh
		uri = 'https://www.funabiki.online/yahoo/'
		@url = "https://auth.login.yahoo.co.jp/yconnect/v1/authorization?response_type=code&client_id=#{ENV['YAHOO_CLIENT_ID']}&redirect_uri=#{uri}&state=#{current_user.id}&scope=openid+profile+email"

		if YahooAPI.access_token_valid?
			if YahooAPI.get_store_status && YahooAPI.get_new_orders
				flash[:notice] = 'ヤフーからデータを更新完了。'
				redirect_to yahoo_orders_path
			else
				flash[:notice] = 'ヤフーからデータを更新出来ません。アドミニストレータに連絡。'
				redirect_to yahoo_orders_path
			end
		else
			redirect_to @url
		end
	end

	# example dev enviornment response URI /yahoo/?code=kk8vbp5r&state=1
	def yahoo_response_auth_code
		@code = params[:code]
		user = User.find(current_user.id)
		if user.id.to_s == params[:state]
			if user.collect_yahoo_token(@code)
				YahooAPI.get_access_token
				flash[:notice] = 'コード取得出来ました。ヤフーからデータを更新開始。'
				redirect_to refresh_yahoo_path
			else
				flash[:notice] = @code + 'のトークンコードを保存できませんでした'
				redirect_to yahoo_orders_path
			end
		else
			flash[:notice] = '違うユーザーで取得のは禁止です。'
			redirect_to yahoo_orders_path
		end
	end

	# GET /yahoo_spreadsheet/:ship_date
	def yahoo_spreadsheet
		require 'spreadsheet'

		ship_date = params[:ship_date]
		orders = YahooOrder.all.where(ship_date: ship_date)

		top_row = %w{送り状種類 クール区分 出荷予定日 お届け予定日 配達時間帯 お届け先電話番号 お届け先電話番号枝番 お届け先郵便番号 お届け先住所 お届け先アパートマンション名 お届け先会社・部門１ お届け先会社・部門２ お届け先名 お届け先名(ｶﾅ) 敬称 ご依頼主電話番号 ご依頼主郵便番号 ご依頼主住所 ご依頼主アパートマンション ご依頼主名 ご依頼主名(ｶﾅ) 品名コード１ 品名１ 品名コード２ 品名２ 荷扱い１ 荷扱い２ 記事 請求先顧客コード 運賃管理番号}

		book = Spreadsheet::Workbook.new
		book.create_worksheet :name => 'ヤマトクロネコ外部データ'
		book.worksheet(0).insert_row(0, top_row)
		orders.each_with_index do |order, i|
			book.worksheet(0).insert_row((i + 1), order.yamato_shipping_format)
		end

		spreadsheet = StringIO.new 
		book.write spreadsheet 
		send_data spreadsheet.string, :filename => "yahoo-oystersisters-#{ship_date}.xls", :type =>  "application/vnd.ms-excel"

	end

	# GET /yahoo_csv/:ship_date
	def yahoo_csv
		require 'spreadsheet'
		ship_date = params[:ship_date]
		orders = YahooOrder.all.where(ship_date: ship_date)
		shipping_csv = CSV.generate(row_sep: "\r\n", encoding: Encoding::SJIS, headers: true) do |csv|
			csv << %w{送り状種類 クール区分 出荷予定日 お届け予定日 配達時間帯 お届け先電話番号 お届け先電話番号枝番 お届け先郵便番号 お届け先住所 お届け先アパートマンション名 お届け先会社・部門１ お届け先会社・部門２ お届け先名 お届け先名(ｶﾅ) 敬称 ご依頼主電話番号 ご依頼主郵便番号 ご依頼主住所 ご依頼主アパートマンション ご依頼主名 ご依頼主名(ｶﾅ) 品名コード１ 品名１ 品名コード２ 品名２ 荷扱い１ 荷扱い２ 記事 請求先顧客コード 運賃管理番号}
			orders.each do |order|
				csv << order.yamato_shipping_format
			end
		end
		respond_to do |format|
			format.csv do
				send_data shipping_csv, filename: "yahoo-oystersisters-#{ship_date}.csv", disposition: :attachment, type: "text/csv"
			end
		end
	end

	# GET /yahoo_shipping_list
	# GET /yahoo_shipping_list
	def yahoo_shipping_list
		puts params
		redirect_to yahoo_orders_path
	end

	# GET /yahoo_orders/1
	# GET /yahoo_orders/1.json
	def show
	end

	# DELETE /yahoo_orders/1
	# DELETE /yahoo_orders/1.json
	def destroy
		@yahoo_order.destroy
		respond_to do |format|
			format.html { redirect_to yahoo_orders_url, notice: '削除しました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_yahoo_order
			@yahoo_order = YahooOrder.find(params[:id])
		end

		def yahoo_order_params
			params.permit(:start, :end, :code, :format, :orders, :date, :_)
		end
end
