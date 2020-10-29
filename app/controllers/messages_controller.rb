class MessagesController < ApplicationController
	before_action :set_message, only: [:print_message, :destroy]


	# DELETE /profits/1
	def print_message
		@message = Message.find(message_params['id'])
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	# DELETE /message/1
	def destroy
        @message.destroy
		@id = @message.id
		respond_to do |format|
			format.js { render 'destroy_message', layout: false }
		end

	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_message
			@message = Message.find(params[:id])
		end

		def message_params
			params.permit(:id, :user, :model, :message, :state, :created_at, :updated_at)
		end

end
