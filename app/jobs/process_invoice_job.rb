class ProcessInvoiceJob < ApplicationJob
	queue_as :default

	def perform(invoice)
		invoice.start_date_str = invoice.start_date.to_s
		invoice.end_date_str = invoice.end_date.to_s

		# Sakoshi All Suppliers
		sakoshi_all_pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'sakoshi',
			export_format: 'all',
			password: invoice[:data][:passwords]["sakoshi_all_password"]
			).do_payment_pdf
		invoice.location = '坂越'
		invoice.export_format = '生産者まとめ'
		invoice.sakoshi_all_pdf = CarrierStringInvoiceIO.new(sakoshi_all_pdf_data[1].render)
		invoice.save

		# Sakoshi Individual
		sakoshi_seperated_pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'sakoshi',
			export_format: 'individual',
			password: invoice[:data][:passwords]["sakoshi_seperated_password"]
			).do_payment_pdf
		invoice.location = '坂越'
		invoice.export_format =  '各生産者'
		invoice.sakoshi_seperated_pdf = CarrierStringInvoiceIO.new(sakoshi_seperated_pdf_data[1].render)
		invoice.save

		# Aioi All Suppliers
		aioi_all_pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'aioi',
			export_format: 'all',
			password: invoice[:data][:passwords]["aioi_all_password"]
			).do_payment_pdf
		invoice.location = '相生'
		invoice.export_format =  '生産者まとめ'
		invoice.aioi_all_pdf = CarrierStringInvoiceIO.new(aioi_all_pdf_data[1].render)
		invoice.save

		# Aioi Individual
		aioi_seperated_pdf_data = OysterSupply.new(
			start_date: Date.parse(invoice.start_date),
			end_date: Date.parse(invoice.end_date),
			location: 'aioi',
			export_format: 'individual',
			password: invoice[:data][:passwords]["aioi_seperated_password"]
			).do_payment_pdf
		invoice.location = '相生'
		invoice.export_format = '各生産者'
		invoice.aioi_seperated_pdf = CarrierStringInvoiceIO.new(aioi_seperated_pdf_data[1].render)
		invoice.data[:processing] = false
		invoice.save

		sakoshi_all_pdf_data = nil
		sakoshi_seperated_pdf_data = nil
		aioi_all_pdf_data = nil
		aioi_seperated_pdf_data = nil
		GC.start
	end
end
