class FrozenOystersController < ApplicationController
	before_action :set_frozen_oyster, only: [:show, :edit, :update, :destroy]
	before_action :check_status
	before_action :set_products

	def set_products
		@frozen_products = Product.where(product_type: '冷凍')
	end

	def check_status
		return unless !current_user.admin?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	# GET /frozen_oysters
	# GET /frozen_oysters.json
	def index
		@frozen_oysters = FrozenOyster.all.order(:manufacture_date, :ampm).reverse
		new
	end

	def insert_frozen_data
		params[:frozen_oyster] == 'new' ? (new) : (@frozen_oyster = FrozenOyster.find(params[:frozen_oyster]))
		@frozen_oyster.fix_empty_products
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	# GET /frozen_oysters/1
	# GET /frozen_oysters/1.json
	def show
	end

	# GET /frozen_oysters/new
	def new
		@frozen_oyster = FrozenOyster.new
		Time.now.hour < 12 ? (@frozen_oyster.ampm = 'am') : (@frozen_oyster.ampm = 'pm')
		@frozen_oyster.manufacture_date = Date.today.strftime("%Y年%m月%d日")
		@frozen_oyster.finished_packs = Hash.new
		@frozen_oyster.fix_empty_products
		@frozen_oyster.set_nil_to_zero
		@frozen_oyster.losses = Hash.new
	end

	# GET /frozen_oysters/1/edit
	def edit
		@frozen_oyster.fix_empty_products
	end

	# POST /frozen_oysters
	# POST /frozen_oysters.json
	def create
		@frozen_oyster = FrozenOyster.new(frozen_oyster_params)

		respond_to do |format|
			if @frozen_oyster.save
				format.html { redirect_to @frozen_oyster, notice: '冷凍データを追加しました。' }
				format.json { render :show, status: :created, location: @frozen_oyster }
			else
				format.html { render :new }
				format.json { render json: @frozen_oyster.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /frozen_oysters/1
	# PATCH/PUT /frozen_oysters/1.json
	def update
		respond_to do |format|
			if @frozen_oyster.update(frozen_oyster_params)
				format.html { redirect_to @frozen_oyster, notice: '冷凍データを更新しました。' }
				format.json { render :show, status: :ok, location: @frozen_oyster }
			else
				format.html { render :edit }
				format.json { render json: @frozen_oyster.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /frozen_oysters/1
	# DELETE /frozen_oysters/1.json
	def destroy
		@frozen_oyster.destroy
		respond_to do |format|
			format.html { redirect_to frozen_oysters_url, notice: '冷凍データを削除しました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_frozen_oyster
			@frozen_oyster = FrozenOyster.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def frozen_oyster_params
			params.require(:frozen_oyster).permit(:hyogo_raw, :okayama_raw, { frozen_l: {} }, { frozen_ll: {} }, { finished_packs: {} }, :manufacture_date, :ampm, { losses: {} })
		end
end
