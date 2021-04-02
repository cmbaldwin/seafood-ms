class ManifestsController < ApplicationController
	before_action :set_manifest, only: [:show, :edit, :update, :destroy, :pdf]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end
	
	# GET /manifests
	# GET /manifests.json
	def index
		Time.zone = 'Tokyo'
		days = Time.days_in_month(Time.now.month, Time.now.year)
		@manifests = Manifest.order(sales_date: :desc).paginate(:page => params[:page], :per_page => days)
	end

	# GET /manifests/1
	# GET /manifests/1.json
	def show
		wc_check
		#bot_response = HTTParty.post('https://thawing-journey-94236.herokuapp.com/api?admin[email]=' + ENV['BOT_LOGIN'] + '&admin[password]=' + ENV['BOT_PASSWORD'])
		#ap bot_response.parsed_response
	end

	# GET /manifests/new
	def new
		@manifest = Manifest.new
		@manifest[:sales_date] = Date.today.strftime('%Y年%m月%d日')
	end

	# GET /manifests/csv
	def csv
		
	end

	# GET /manifests/csv_upload
	def csv_upload
		require "csv"
		require "json"

		csv_text = File.read(open(params[:csv]))
		parsed = CSV.parse(csv_text, {:headers => true, :encoding => 'Shift_JIS'})
		csv_hash = Hash.new
		parsed.each_with_index do |row, i|
			if i == 0
				@header_array = row.to_s.encode("utf-8").gsub(/[［］\R]/, '').split(',')
				@set_length = @header_array.length
				@order_date_index = @header_array.index('伝票日付')
				@order_number_index = @header_array.index('伝票No')
				@sub_order_number_index = @header_array.index('伝票明細ID_SYSTEM')
			else
				encoded = row.to_s.encode("utf-8").gsub(/[［］\R]/, '').split(',')
				if encoded.length == @set_length
					order_date = encoded[@order_date_index]
					order_number = encoded[@order_number_index]
					sub_order_number = encoded[@sub_order_number_index]
					csv_hash[order_date] ? () : csv_hash[order_date] = Hash.new
					csv_hash[order_date][order_number] ? () : csv_hash[order_date][order_number] = Hash.new
					csv_hash[order_date][order_number][sub_order_number] = Hash.new
					encoded.each_with_index do |col, ic|
						csv_hash[order_date][order_number][sub_order_number][@header_array[ic]] = col.gsub(/[\\\"\"]/, '').to_s
					end
				end
			end
		end

		render inline: csv_hash.to_s, :layout => "application"
	end


	# GET /manifests/csv_result
	def csv_result

	end

	# GET /manifests/1/edit
	def edit
		@manifest.get_infomart
		@manifest.get_woocommerce_orders
		@manifest.save

		respond_to do |format|
			if @manifest.save
				format.html { redirect_to @manifest, notice: '発送リストを編集されました。' }
				format.json { render :show, status: :ok, location: @manifest }
			else
				format.html { redirect_to @manifest, notice: @manifest.errors }
				format.json { render json: @manifest.errors, status: :unprocessable_entity }
			end
		end
	end

	def empty_manifest
		filename = "（#{params[:type]}）無字発送リスト"

		send_data PrawnPDF.empty_manifest(filename, params[:type]).render,
			type: 'application/pdf', 
			disposition: :inline
	end

	def pdf
		@filename = "InfoMart/Funabiki.infoの出荷表（#{@manifest.sales_date}）.pdf"
		message = Message.new(user: current_user.id, model: 'manifest', state: false, message: "InfoMart/Funabiki.infoの出荷表を作成中…", data: {manifest_id: @manifest.id, filename: @filename, expiration: (DateTime.now + 1.day)})
		message.save
		ManifestPdfWorker.perform_async(@manifest.id, message.id)
	end

	# POST /manifests
	# POST /manifests.json
	def create
		@manifest = Manifest.new(manifest_params)

		@manifest.get_infomart
		@manifest.get_woocommerce_orders
		@manifest.save

		respond_to do |format|
			if @manifest.save
				format.html { redirect_to @manifest, notice: '発送リストを作成されました。' }
				format.json { render :show, status: :created, location: @manifest }
			else
				format.html { render :new }
				format.json { render json: @manifest.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /manifests/1
	# PATCH/PUT /manifests/1.json
	def update
		if @manifest.update(manifest_params)
			@manifest.get_infomart
			@manifest.get_woocommerce_orders
			@manifest.save
		end

		respond_to do |format|
			if @manifest.update(manifest_params)
				format.html { redirect_to @manifest, notice: '発送リストを編集されました。' }
				format.json { render :show, status: :ok, location: @manifest }
			else
				format.html { render :edit }
				format.json { render json: @manifest.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /manifests/1
	# DELETE /manifests/1.json
	def destroy
		@manifest.destroy
		respond_to do |format|
			format.html { redirect_to manifests_url, notice: '発送リストを削除されました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_manifest
			@manifest = Manifest.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def manifest_params
			params.require(:manifest).permit(:sales_date, :infomart_orders, :online_shop_orders, :csv, parsed: {}, restaurant_ids: [])
		end
end
