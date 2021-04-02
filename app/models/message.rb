class Message < ApplicationRecord
	before_save :set_dismissed
	after_commit :notify

	mount_uploader :document, MessageDocumentUploader

	validates_presence_of :user
	validates_presence_of :model
	validates_presence_of :message

	serialize :data, Hash

	def set_dismissed
		(self.data[:dismissed] == false) if self.data[:dismissed].nil?
	end

	def dismissed
		self.data[:dismissed]
	end

	def notify
		unless dismissed
			ActionCable.server.broadcast "notifications_channel_#{self.user.to_s}", {id: self.id}
		end
	end

	def status
		self.state.nil? ? (:error) : (self.state ? :completed : :processing)
	end

	def border
		self.status.nil? ? ('border-danger') : (self.status == :processing ? ('border-warning') : ('border-success')) 
	end

end
