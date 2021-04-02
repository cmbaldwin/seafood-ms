class ProcessInvoiceWorker
	include Sidekiq::Worker

	def perform(invoice_id, user_id, message_id)
		invoice = OysterInvoice.find(invoice_id)
		msg = Message.find(message_id)
		invoice.data[:message] = message_id
		start_date = invoice.start_date
		end_date = invoice.end_date

		# Sakoshi All Suppliers
		pdf_data = PrawnPDF.oyster_invoice(start_date, end_date, 'sakoshi', 'all', invoice[:data][:passwords]["sakoshi_all_password"])
		invoice.location = '坂越'
		invoice.export_format = '生産者まとめ'
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		invoice.sakoshi_all_pdf = pdf
		invoice.save
		pdf.close
		pdf_data = nil

		# Sakoshi Individual
		invoice.reload
		pdf_data = PrawnPDF.oyster_invoice(start_date, end_date, 'sakoshi', 'individual', invoice[:data][:passwords]["sakoshi_seperated_password"])
		invoice.location = '坂越'
		invoice.export_format =  '各生産者'
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		invoice.sakoshi_seperated_pdf = pdf
		invoice.save
		pdf.close
		pdf_data = nil

		# Aioi All Suppliers
		invoice.reload
		pdf_data = PrawnPDF.oyster_invoice(start_date, end_date, 'aioi', 'all', invoice[:data][:passwords]["aioi_all_password"])
		invoice.location = '相生'
		invoice.export_format =  '生産者まとめ'
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		invoice.aioi_all_pdf = pdf
		invoice.save
		pdf.close
		pdf_data = nil

		# Aioi Individual
		invoice.reload
		pdf_data = PrawnPDF.oyster_invoice(start_date, end_date, 'aioi', 'individual', invoice[:data][:passwords]["aioi_seperated_password"])
		invoice.location = '相生'
		invoice.export_format = '各生産者'
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		invoice.aioi_seperated_pdf = pdf
		invoice.data[:processing] = false
		invoice.save
		pdf.close
		pdf_data = nil
		pdf = nil
		GC.start
		msg.update(state: true, message: '牡蠣原料仕切り作成完了')
	end
end
