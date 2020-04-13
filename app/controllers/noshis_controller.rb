class NoshisController < ApplicationController
	before_action :set_noshi, only: [:show, :edit, :update, :destroy]
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.employee? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	# GET /noshis
	# GET /noshis.json
	def index
		@noshis = Noshi.search(params[:term]).paginate(:page => params[:page], :per_page => 9)
	end

	# GET /noshis/1
	# GET /noshis/1.json
	def show

	end

	# GET /noshis/new
	def new
		@noshi = Noshi.new
		params[:namae] ? (@noshi.namae = params[:namae]) : ()
		params[:ntype] ? (@noshi.ntype = params[:ntype]) : (@noshi.ntype = 1)
	end

	# GET /noshis/1/edit
	def edit
	end

	# POST /noshis
	# POST /noshis.json

	def create
		@noshi = Noshi.new(noshi_params)

		@noshi.make_noshi

		respond_to do |format|
			if @noshi.save
			format.html { redirect_to @noshi, notice: '熨斗が作成されました。' }
			format.json { render :show, status: :created, location: @noshi }
			else
			format.html { render :new }
			format.json { render json: @noshi.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /noshis/1
	# PATCH/PUT /noshis/1.json
	def update
		respond_to do |format|
			if @noshi.update(noshi_params)
			format.html { redirect_to @noshi, notice: '熨斗が編集されました。' }
			format.json { render :show, status: :ok, location: @noshi }
			else
			format.html { render :edit }
			format.json { render json: @noshi.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /noshis/1
	# DELETE /noshis/1.json
	def destroy
	@noshi.destroy

		respond_to do |format|
			format.html { redirect_to noshis_url, notice: '熨斗が削除されました。' }
			format.json { head :no_content }
		end
	end

	def destroy_multiple

		Noshi.destroy(params[:noshi_ids])

		noshi_count = params[:noshi_ids].count.to_s

		respond_to do |format|
			format.html { redirect_to noshis_url, notice: noshi_count + '消されました。' }
			format.json { head :no_content }
		end

	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_noshi
		@noshi = Noshi.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def noshi_params
		params.require(:noshi).permit(:ntype, :omotegaki, :namae, :namae2, :namae3, :namae4, :namae5, :image, :term)
	end
end
