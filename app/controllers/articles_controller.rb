class ArticlesController < ApplicationController

	before_action :authenticate_user!, only: :index
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	def index
		@articles = Article.where(:category_id => '1') #set the initial value for the single_article partial
		@categories = Category.all
		@category = Category.new
	end


	def destroy_multiple
	  Categories.destroy(params[:categories])
	    respond_to do |format|
	      format.html { redirect_to categories_path }
	      format.json { head :no_content }
	    end
	end

	def from_category
		@selected = Article.where(:category_id => params[:cat_id])
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def show
		@article = Article.find(params[:id])
	end

	def new
		@article = Article.new
	end

	def edit
		@article = Article.find(params[:id])
	end

	def create
		@article = Article.new(article_params)
		@article.user_id = current_user.id

		if @article.save
			redirect_to @article
		else
			render 'new'
		end
	end

	def update
		@article = Article.find(params[:id])
		@article.user_id = current_user.id

		if @article.update(article_params)
			redirect_to @article
		else
			render 'edit'
		end
	end

	def destroy
		@article = Article.find(params[:id])
		@article.destroy

		redirect_to articles_path
	end

	private
		def article_params
			params.require(:article).permit(:title, :text, :user_id, :category_id)
		end
end
