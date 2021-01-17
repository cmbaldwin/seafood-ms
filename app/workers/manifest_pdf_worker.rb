class ManifestPdfWorker
	include Sidekiq::Worker

	def perform(manifest_id, message_id)
		message = Message.find(message_id)
		@manifest = Manifest.find(manifest_id)
		pdf_data = @manifest.do_pdf
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		pdf_data = nil
		pdf = nil
		GC.start
		message.update(state: true, message: 'InfoMart/Funabiki.infoの出荷表作成完了。')
		File.delete(Rails.root + 'PDF.pdf') if File.exist?(Rails.root + 'PDF.pdf')
	end
end
