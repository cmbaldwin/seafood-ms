class ApplicationMailer < ActionMailer::Base
	require 'sendgrid-ruby'
	include SendGrid

	layout 'mailer'
	# @user = current_user <= This dosen't work, server can't start
	# mail(to: user.email, subject: "Confirm Account", body: "Click this link to confirm...")
	default from: ENV['MAIL_SENDER']
	
end
