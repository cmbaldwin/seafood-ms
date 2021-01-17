class RakutenManifestWorker
	include Sidekiq::Worker

	def perform(r_manifest_id, seperated, user_id, message_id, include_yahoo)
		message = Message.find(message_id)
		@r_manifest = RManifest.find(r_manifest_id)
		seperated ? (pdf_data = @r_manifest.do_seperated_pdf) : (pdf_data = @r_manifest.do_new_pdf(include_yahoo))
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		message.update(state: true, message: '楽天出荷表作成完了')
	end
end
