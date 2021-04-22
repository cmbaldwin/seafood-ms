class YahooUpdateWorker
	include Sidekiq::Worker

	def perform(user_id, message_id)
		message = Message.find(message_id)
		current_user = User.find(user_id)
		client = YahooAPI.new(current_user)
		client.acquire_auth_token unless client.authorized?
		if client.get_status(true, message_id) && client.update_processing(message_id)
			message.update(state: true, message: 'ヤフー注文データ更新完了。', data: {expiration: (DateTime.now + 10.seconds)})
		else
			message.update(message: 'エラーがありました、管理者に連絡してください。', data: {expiration: (DateTime.now + 10.seconds)})
		end
	end
end
