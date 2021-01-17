class YahooShippingListWorker
	include Sidekiq::Worker

	def perform(ship_date, message_id, filename)
		message = Message.find(message_id)
		pdf_data = PrawnPDF.yahoo_shipping_pdf(ship_date, filename)
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		message.update(state: true, message: 'ヤフー出荷表作成完了')
		File.delete(Rails.root + filename) if File.exist?(Rails.root + filename)
		GC.start
	end
end
