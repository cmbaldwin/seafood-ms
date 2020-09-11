class RManifestsController < ApplicationController
	before_action :set_r_manifest, only: [:show, :edit, :update, :destroy, :pdf, :new_pdf, :seperated_pdf, :reciept]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end
	
	# GET /r_manifests
	# GET /r_manifests.json
	def index
		Time.zone = 'Tokyo'
		days = Time.days_in_month(Time.now.month, Time.now.year)
		@r_manifests = RManifest.order(sales_date: :desc).paginate(:page => params[:page], :per_page => days)
	end

	def rakuten_check
		rakuten_api_client = RakutenAPI.new
		@rakuten_shinki = rakuten_api_client.get_details_by_ids(rakuten_api_client.get_shinki_without_shipdate_ids)
	end

	# GET /r_manifests/1 
	# GET /r_manifests/1.json
	def show
		time_setup
		rakuten_today = RManifest.where(:sales_date => @today).first
		if rakuten_today
			@r_manifest.sales_date == (rakuten_today.sales_date) ? rakuten_check : ()
		end
	end

	# GET /r_manifests/new
	def new
		@r_manifest = RManifest.new
		@r_manifest[:sales_date] = Date.today.strftime('%Y年%m月%d日')
	end

	# GET /r_manifests/1/edit
	def edit
		@r_manifest.get_order_details_by_api
		@r_manifest.save

		respond_to do |format|
			if @r_manifest.save
				format.html { redirect_to @r_manifest, notice: '発送リストを編集されました。' }
				format.json { render :show, status: :ok, location: @r_manifest }
			else
				format.html { redirect_to @r_manifest, notice: @r_manifest.errors }
				format.json { render json: @r_manifest.errors, status: :unprocessable_entity }
			end
		end
	end

	def seperated_pdf
		pdf = @r_manifest.do_seperated_pdf
		send_data pdf.render,
			type: 'application/pdf', 
			disposition: :inline
		pdf = nil
		File.delete(Rails.root + 'PDF.pdf') if File.exist?(Rails.root + 'PDF.pdf')
		GC.start
	end

	def new_pdf
		pdf = @r_manifest.do_new_pdf
		send_data pdf.render,
			type: 'application/pdf', 
			disposition: :inline
		pdf = nil
		File.delete(Rails.root + 'PDF.pdf') if File.exist?(Rails.root + 'PDF.pdf')
		GC.start
	end

	def reciept
		# Set the options
		@r_manifest.options = params[:r_manifest]
		pdf = @r_manifest.do_reciept
		send_data pdf.render,
			type: 'application/pdf', 
			disposition: :inline
		pdf = nil
		File.delete(Rails.root + 'PDF.pdf') if File.exist?(Rails.root + 'PDF.pdf')
	end

	# POST /r_manifests
	# POST /r_manifests.json
	def create
		@r_manifest = RManifest.new(r_manifest_params)

		if @r_manifest.save
			@r_manifest.get_order_details_by_api
		end

		respond_to do |format|
			if @r_manifest.save
				format.html { redirect_to @r_manifest, notice: '発送リストを作成されました。' }
				format.json { render :show, status: :created, location: @r_manifest }
			else
				format.html { render :new }
				format.json { render json: @r_manifest.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /r_manifests/1
	# PATCH/PUT /r_manifests/1.json
	def update

		if @r_manifest.save
			@r_manifest.get_order_details_by_api
		end

		respond_to do |format|
			if @r_manifest.update(r_manifest_params)
				format.html { redirect_to @r_manifest, notice: '発送リストを編集されました。' }
				format.json { render :show, status: :ok, location: @r_manifest }
			else
				format.html { render :edit }
				format.json { render json: @r_manifest.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /r_manifests/1
	# DELETE /r_manifests/1.json
	def destroy
		@r_manifest.destroy
		respond_to do |format|
			format.html { redirect_to r_manifests_url, notice: '発送リストを削除されました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_r_manifest
			@r_manifest = RManifest.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def r_manifest_params
			params.require(:r_manifest).permit(:orders_hash, :Rakuten_Order, :sales_date, :new_orders_hash)
		end
end
