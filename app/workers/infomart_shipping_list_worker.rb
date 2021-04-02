class InfomartShippingListWorker
	include Sidekiq::Worker

	def perform(ship_date, message_id, filename, include_online)
		message = Message.find(message_id)
		pdf_data = PrawnPDF.infomart(ship_date, filename, include_online)
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		message.update(state: true, message: 'Infomart出荷表作成完了')
		File.delete(Rails.root + filename) if File.exist?(Rails.root + filename)
		GC.start
	end
end
