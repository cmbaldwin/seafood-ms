class CategoryController < ApplicationController
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end
	
	def index
		@categories = Category.all
		@category = Category.new
	end

	def show
		@category = Category.find(params[:id])
	end

	def new
		@category = Category.new
	end

	def edit
		@category = Category.find(params[:id])
	end

	def create
		@category = Category.new(category_params)

		if @article.save
			redirect_to @article
		else
			render 'new'
		end
	end

	def update
		@category = Category.find(params[:id])
		@category.user_id = current_user.id

		if @category.update(category_params)
			redirect_to @category
		else
			render 'edit'
		end
	end

	def destroy
		@category = Category.find(params[:id])
		@category.destroy

		redirect_to category_path
	end

end
