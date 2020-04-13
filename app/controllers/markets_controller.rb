class MarketsController < ApplicationController
	before_action :set_market, only: [:show, :edit, :update, :destroy]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end
	
	# GET /markets
	# GET /markets.json
	def index
		@markets = Market.order('mjsnumber').all
	end

	# GET /markets/1
	# GET /markets/1.json
	def show
	end

	# GET /markets/new
	def new
		@market = Market.new
		@market.brokerage = true
	end

	# GET /markets/1/edit
	def edit
	end

	# POST /markets
	# POST /markets.json
	def create
		@market = Market.new(market_params)
		@market.history = Hash.new

		respond_to do |format|
			if @market.save
				format.html { redirect_to @market, notice: '市場を作成されました。' }
				format.json { render :show, status: :created, location: @market }
			else
				format.html { render :new }
				format.json { render json: @market.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /markets/1
	# PATCH/PUT /markets/1.json
	def update
		@market = Market.find(params[:id])
		@market.do_history

		respond_to do |format|
			if @market.update(market_params)
				format.html { redirect_to @market, notice: '市場を編集されました。' }
				format.json { render :show, status: :ok, location: @market }
			else
				format.html { render :edit }
				format.json { render json: @market.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /markets/1
	# DELETE /markets/1.json
	def destroy
		@market.destroy
		respond_to do |format|
			format.html { redirect_to markets_url, notice: '市場を削除されました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_market
			@market = Market.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def market_params
			params.require(:market).permit(:mjsnumber, :namae, :color, :nick, :zip, :address, :brokerage, :phone, :repphone, :fax, :cost, :block_cost, :one_time_cost, :one_time_cost_description, :optional_cost, :optional_cost_description, :handling, :history, product_ids: [])
		end
end