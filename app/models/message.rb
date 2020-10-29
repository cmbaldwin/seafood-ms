class Message < ApplicationRecord
	after_save :notify

	mount_uploader :document, MessageDocumentUploader

	validates_presence_of :user
	validates_presence_of :model
	validates_presence_of :message

	serialize :data, Hash

	def notify
		ActionCable.server.broadcast "notifications_channel_#{self.user.to_s}", {id: self.id}
	end

	def status
		self.state.nil? ? (:error) : (self.state ? :completed : :processing)
	end

	def border
		self.status.nil? ? ('border-danger') : (self.status == :processing ? ('border-warning') : ('border-success')) 
	end

end
