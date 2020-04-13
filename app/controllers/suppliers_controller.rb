class SuppliersController < ApplicationController
	before_action :set_supplier, only: [:show, :edit, :update, :destroy]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user? || current_user.employee?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	# GET /suppliers
	# GET /suppliers.json
	def index
		@suppliers = Supplier.all
	end

	# GET /suppliers/1
	# GET /suppliers/1.json
	def show
	end

	# GET /suppliers/new
	def new
		@supplier = Supplier.new
	end

	# GET /suppliers/1/edit
	def edit
	end

	# POST /suppliers
	# POST /suppliers.json
	def create
		@supplier = Supplier.new(supplier_params)

		respond_to do |format|
			if @supplier.save
				format.html { redirect_to @supplier, notice: '生産者を作成されました。' }
				format.json { render :show, status: :created, location: @supplier }
			else
				format.html { render :new }
				format.json { render json: @supplier.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /suppliers/1
	# PATCH/PUT /suppliers/1.json
	def update
		respond_to do |format|
			if @supplier.update(supplier_params)
				format.html { redirect_to @supplier, notice: '生産者を編集されました。' }
				format.json { render :show, status: :ok, location: @supplier }
			else
				format.html { render :edit }
				format.json { render json: @supplier.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /suppliers/1
	# DELETE /suppliers/1.json
	def destroy
		@supplier.destroy
		respond_to do |format|
			format.html { redirect_to suppliers_url, notice: '生産者を削除されました。' }
			format.json { head :no_content }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_supplier
			@supplier = Supplier.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def supplier_params
			params.require(:supplier).permit(:company_name, :supplier_number, :address, :home_address, {:representatives => []}, :location, :phone)
		end
end
