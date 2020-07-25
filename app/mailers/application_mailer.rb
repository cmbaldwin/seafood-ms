class ApplicationMailer < ActionMailer::Base
	require 'sendgrid-ruby'
	include SendGrid

	default from: ENV['MAIL_SENDER']
	layout 'mailer'
	
end
