class InvoiceMailer < ApplicationMailer
	require 'open-uri'
	default from: ENV['MAIL_SENDER']

	def sakoshi_invoice_email
		@invoice = params[:invoice]
		@locale = '坂越'
		mail(to: @invoice[:sakoshi_emails], subject: '船曳商店ー支払い明細書 ' + @locale + '（' + @invoice.display_date + '）')
	end

	def aioi_invoice_email
		@invoice = params[:invoice]
		@locale = '相生'
		mail(to: @invoice[:aioi_emails], subject: '船曳商店ー支払い明細書 ' + @locale + '（' + @invoice.display_date + '）')
	end
	
	def test_mail
		mail(to: ENV['MAIL_SENDER'], subject: 'Test')
	end
end
