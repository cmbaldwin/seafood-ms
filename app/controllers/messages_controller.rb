class MessagesController < ApplicationController
	before_action :set_message, only: [:print_message, :print_model_message, :set_dismissed, :destroy]

	def display_messages
		user_messsages = Message.where(user: message_params[:user])
		@messages = user_messsages.map{|msg| msg if (msg.data[:dismissed].nil? || msg.data[:dismissed] == false)}.compact
	end

	def refresh
		respond_to do |format|
			format.js { render 'refresh_messages', layout: false }
		end
	end

	def print_message
		unless @message.nil?
			unless @message.data[:dismissed]
				respond_to do |format|
					format.js { render 'print_message', layout: false }
				end
			else
				# Message was dismissed, it will be rendered when the user hits the message display button
				head :no_content
			end
		else
			puts "Cannot print message. Message with id##{params[:id]} was destroyed."
			head :no_content
		end
	end

	def print_model_message
		# for when the print_message method is called from within a different model path
		print_message
	end

	def set_dismissed
		unless @message.data[:dismissed]
			@message.data[:dismissed] = true
			@message.save
		end
	end

	def clear_expired_messages
		Message.where(user: message_params[:user]).each do |message|
			exp = message.data[:expiration]
			message.destroy if exp < DateTime.now if exp
		end
	end

	# DELETE /message/1
	def destroy
		@id = @message.id
		@message.destroy
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
