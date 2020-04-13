class ProfitsController < ApplicationController
	before_action :set_profit, only: [:show, :edit, :update, :destroy, :autosave_tab]
	before_action :check_status
	before_action :check_subtotals, only: [:show]
	before_action :set_types_markets_products, only: [:show, :new, :edit]

	def check_status
		return unless !current_user.admin?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	def check_subtotals
		if @profit.subtotals.nil?
			@profit.subtotals = @profit.get_subtotals
			@profit.save
		end
	end
	
	def set_types_markets_products
		@products = Product.order('namae DESC').all
		@markets = Market.order('mjsnumber').all
		@types = Set.new
		@products.each do |product|
			@types.add(product.product_type)
		end
		@types_with_markets = Hash.new
		i = 0
		@types.each do |t|
			market_types = Set.new
			@types_with_markets[t] = Array.new
			@markets.each do |m|
				m.products.each do |k|
					market_types.add(k.product_type)
				end
				market_types.each do |mt|
					if t == mt
						@types_with_markets[t] << m.namae
					end
				end
			end
			i += 1
		end
		@types_hash = {"1"=>"トレイ", "2"=>"チューブ", "3"=>"水切り", "4"=>"殻付き", "5"=>"冷凍", "6"=>"単品"}
	end

	# GET /profits
	# GET /profits.json
	def index
		days = Time.days_in_month(Time.now.month, Time.now.year)
		@profits = Profit.order(sales_date: :desc, ampm: :asc).paginate(:page => params[:page], :per_page => days)
		@profits.each do |profit|
			if profit.subtotals.nil?
				profit.subtotals = profit.get_subtotals
				profit.save
			end
		end
	end

	# GET /profits/1
	# GET /profits/1.json
	def show
	end

	# GET /profits/new
	def new
		@market = Market.order('mjsnumber').all.first
		@profit = Profit.new
	end

	def new_tabs
		@market = Market.order('mjsnumber').all.first
		@profit = Profit.new
	end

	def fetch_market
		@market = Market.find(params[:market_id])
		@profit = Profit.find(params[:profit])
		if @profit.nil?
			@profit = Profit.new
		end
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	# GET /profits/1/edit
	def edit
		@market = Market.order('mjsnumber').all.first
	end

	# POST /profits
	# POST /profits.json
	def create
		@profit = Profit.new(profit_params)
		@profit.figures = Hash.new
		@profit.figures[0] = 0
		@profit.totals = Hash.new
		respond_to do |format|
			if @profit.save
				format.html { redirect_to edit_profit_path(@profit), notice: '計算表を作成されました。'}
			else
				format.html { render :new_tabs, notice: @profit.errors }
				format.json { render json: @profit.errors, status: :unprocessable_entity }
			end
		end
	end

	# POST /profits
	# POST /profits.json
	def update
		@profit.calculate_tab
		@profit.sanbyaku_extra_cost_fix
		@profit.subtotals = @profit.get_subtotals

		respond_to do |format|
			if @profit.save
				format.html { redirect_to @profit, notice: '計算完了しました。'}
				format.json { render :show, status: :created, location: @profit }
			else
				format.html { render :edit }
				format.json { render json: @profit.errors, status: :unprocessable_entity }
			end
		end
	end

	def autosave_tab
		@profit.new_figures = profit_params[:figures].to_h
		@profit.do_autosave
		
		if @profit.save
			head :accepted, location: profits_path(@profit)
		else
			head :badrequest
			@profit.errors.full_messages.each do |error|
				logger.debug error.to_s
			end
		end
	end

	# DELETE /profits/1
	# DELETE /profits/1.json
	def destroy
        @profit.destroy
		respond_to do |format|
			format.html { redirect_to profits_url }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_profit
			@profit = Profit.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def profit_params
			params.require(:profit).permit(:sales_date, :totals, :debug_figures, :split, :ampm, { :figures => {} }, { :subtotals => {} }, :notes, market_ids: [], product_ids: [])
		end
end
