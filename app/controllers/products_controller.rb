class ProductsController < ApplicationController
	before_action :set_product, only: [:show, :edit, :update, :destroy]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end
	
	# GET /products
	# GET /products.json
	def index
		helpers.types_hash
		@type = '1'
		@products = Product.order('namae').all
		@product = Product.new
	end

	def fetch_products_by_type
		helpers.types_hash
		@type = params[:type_id]
		
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	# GET /insert_product_data/:id
	def insert_product_data
		params[:id] ? (@product = Product.find(params[:id])) : (@product = Product.new)
	end

	# GET /products/1
	# GET /products/1.json
	def show
	end

	# GET /products/new
	def new
		@product = Product.new
		@product.profitable = true
	end

	# GET /products/1/edit
	def edit
	end

	def product_pdf
		@filename = '㈱船曳商店－商品まとめ（' + Date.today.strftime('%y年%m月%d日') + '）.pdf'
		send_data Product.new.do_product_pdf.render, :filename => @filename, type: 'application/pdf', disposition: :inline
		pdf = nil
		File.delete(Rails.root + @filename) if File.exist?(Rails.root + @filename)
		GC.start
	end

	# POST /products
	# POST /products.json
	def create
		@product = Product.new(product_params)
		@product.type_check
		@product.history = Hash.new

		respond_to do |format|
			if @product.save
				format.html { redirect_to @product, notice: '商品を作成されました。' }
				format.json { render :show, status: :created, location: @product }
			else
				format.html { render :new }
				format.json { render json: @product.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /products/1
	# PATCH/PUT /products/1.json
	def update
		@product.type_check
		@product.refresh_history
		respond_to do |format|
			if @product.update(product_params)
				format.html { redirect_to @product, notice: '商品を編集されました。' }
				format.json { render :show, status: :ok, location: @product }
			else
				format.html { render :edit }
				format.json { render json: @product.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /products/1
	# DELETE /products/1.json
	def destroy
		@product.destroy
		respond_to do |format|
			format.html { redirect_to products_url, notice: '商品を消されました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_product
			@product = Product.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def product_params
			params.require(:product).permit(:namae, :profitable, :grams, :cost, :extra_expense, :product_type, :count, :multiplier, :history, material_ids: [], market_ids: [])
		end
end
