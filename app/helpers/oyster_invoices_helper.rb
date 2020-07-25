module OysterInvoicesHelper

	def invoice_display_date(invoice)
		invoice.start_date + ' ~ ' + (Date.parse(invoice.end_date) - 1.day).to_s
	end
	
end
