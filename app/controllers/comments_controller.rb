class CommentsController < ApplicationController
	before_action :check_status

	def check_status
		return unless !current_user.approved? || current_user.supplier? || current_user.user?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end
	
	def create
		@article = Article.find(params[:article_id])
		@comment = @article.comments.create(comment_params)
		@comment.user_id = current_user.id
		if @article.save
			redirect_to @article
		else
			render 'new'
		end
	end

	def destroy
		@article = Article.find(params[:article_id])
		@comment = @article.comments.find(params[:id])
		@comment.destroy
		redirect_to article_path(@article)
	end

	private 
	def comment_params
		params.require(:comment).permit(:title, :body)
	end
end
