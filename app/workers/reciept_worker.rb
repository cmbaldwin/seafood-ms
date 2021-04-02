class RecieptWorker
	include Sidekiq::Worker

	def perform(options, message_id)

		message = Message.find(message_id)
		pdf_data = PrawnPDF.reciept(eval(options).transform_keys{|k| k.to_sym})
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		pdf_data = nil
		pdf = nil
		GC.start
		message.update(state: true, message: '領収証作成完了。')

	end
end
