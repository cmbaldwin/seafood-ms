class ProductsController < ApplicationController
	before_action :set_product, only: [:show, :edit, :update, :destroy]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	def associations
		params ? (puts params) : ()
		@new_associations = Set.new
		@assocation_links = Hash.new
		manifests = Manifest.all
		manifests.map{ |m| m.get_new_associations }.flatten.each{|n| @new_associations << n}
		@associations = Hash.new
		@new_associations.each do |newp|
			@assocation_links[newp] = Array.new
			@associations[newp] = Hash.new
			newp.include?("×") ? (count = (newp[/(?<=×)\d*/]).to_i) : (count = 0)
			@associations[newp]["count"] = count
			@associations[newp]["product_id"] = 0
		end
		manifests.each do |manifest|
			@new_associations.each do |newp|
				links = manifest.check_for_links(newp)
				!links.empty? ? @assocation_links[newp] << links : ()
			end
		end
		@products = Product.where(associated: true).order(:namae)
	end

	def set_associations
		params[:associations].each do |product_name, values|
			if (values["count"] != 0) && !values["product_id"].empty?
				product = Product.find(values["product_id"])
				product.infomart_association.nil? ? (current_associations = Hash.new) : (current_associations = product.infomart_association)
				current_associations[product_name] = values["count"]
				product.infomart_association = current_associations
				product.save
			end
		end
		flash[:notice] = '商品の関連を設定された。'
		redirect_to :associations
	end

	def reset_associations
		if params[:reset]
			params[:reset].each do |association|
				id_name = association.split(',')
				product = Product.find(id_name[0])
				product.infomart_association.delete(id_name[1])
				product.save
			end
			flash[:notice] = '商品の関連を削除された。'
			redirect_to :associations
		else
			flash[:notice] = '選択した商品はなかった。'
			redirect_to :associations
		end
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

	def insert_select_products_by_type
		@type = params[:type_id]
	end

	def insert_product_selected_button
		@product = params[:product_id]
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
		if params[:save_as]
			@product = Product.new(product_params)
			@product.type_check
			@product.history = Hash.new
			respond_to do |format|
				if @product.save
					format.html { redirect_to @product, notice: '商品を編集されました。' }
					format.json { render :show, status: :ok, location: @product }
				else
					format.html { render :edit }
					format.json { render json: @product.errors, status: :unprocessable_entity }
				end
			end
		else
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
			params.require(:product).permit(:namae, :profitable, :grams, :cost, :extra_expense, :product_type, :associated, :count, :multiplier, :history, material_ids: [], market_ids: [])
		end
end
