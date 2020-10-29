class InvoicePreviewWorker
	include Sidekiq::Worker

	def perform(start_date, end_date, location, export_format, user_id, message_id)
		message = Message.find(message_id)
		pdf_data = OysterSupply.new(
			start_date: Date.parse(start_date),
			end_date: Date.parse(end_date),
			location: location,
			export_format: export_format,
			).do_payment_pdf
		message.data[:filename] = "#{location} (#{start_date} ~ #{end_date}) - #{export_format}[#{message.user}-#{DateTime.now.strftime('%Y%m%d%H%M%S')}].pdf"
		pdf = CarrierStringInvoiceIO.new(pdf_data[1].render)
		message.update(document: pdf)
		pdf.close
		pdf_data = nil
		pdf = nil
		GC.start
		message.update(state: true, message: '牡蠣原料仕切りプレビュー作成完了')
	end
end