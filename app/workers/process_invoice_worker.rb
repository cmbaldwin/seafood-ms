class ProcessInvoiceWorker
	include Sidekiq::Worker

	def perform(invoice_id, user_id, message_id)
		invoice = OysterInvoice.find(invoice_id)
		msg = Message.find(message_id)
		invoice.data[:message] = message_id

		# Sakoshi All Suppliers
		pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'sakoshi',
			export_format: 'all',
			password: invoice[:data][:passwords]["sakoshi_all_password"]
			).do_payment_pdf
		invoice.location = '坂越'
		invoice.export_format = '生産者まとめ'
		pdf = CarrierStringInvoiceIO.new(pdf_data[1].render)
		invoice.sakoshi_all_pdf = pdf
		invoice.save
		pdf.close
		pdf_data = nil
		GC.start

		# Sakoshi Individual
		invoice.reload
		pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'sakoshi',
			export_format: 'individual',
			password: invoice[:data][:passwords]["sakoshi_seperated_password"]
			).do_payment_pdf
		invoice.location = '坂越'
		invoice.export_format =  '各生産者'
		pdf = CarrierStringInvoiceIO.new(pdf_data[1].render)
		invoice.sakoshi_seperated_pdf = pdf
		invoice.save
		pdf.close
		pdf_data = nil
		GC.start

		# Aioi All Suppliers
		invoice.reload
		pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'aioi',
			export_format: 'all',
			password: invoice[:data][:passwords]["aioi_all_password"]
			).do_payment_pdf
		invoice.location = '相生'
		invoice.export_format =  '生産者まとめ'
		pdf = CarrierStringInvoiceIO.new(pdf_data[1].render)
		invoice.aioi_all_pdf = pdf
		invoice.save
		pdf.close
		pdf_data = nil
		GC.start

		# Aioi Individual
		invoice.reload
		pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'aioi',
			export_format: 'individual',
			password: invoice[:data][:passwords]["aioi_seperated_password"]
			).do_payment_pdf
		invoice.location = '相生'
		invoice.export_format = '各生産者'
		pdf = CarrierStringInvoiceIO.new(pdf_data[1].render)
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
