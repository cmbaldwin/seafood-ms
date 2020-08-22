class BrowseBotAPI
	include HTTParty

	@admin = User.find(1)

	@header = {"Content-Type" => "multipart/form-data"}

	def self.acquire_auth_code
		puts 'Acquiring bot authorization code'
		payload = { email: ENV['API_BROWSEBOT_USER'], password: ENV['API_BROWSEBOT_PASS']}
		request = HTTParty.post('https://api-browsebot.herokuapp.com/api/v1/authenticate', headers: @headers, body: payload)
		if request["auth_token"]
			puts 'Acquired:'
			@admin.data[:browse_bot] = Hash.new unless @admin.data[:browse_bot]
			@admin.data[:browse_bot][:authorization] = Hash.new unless @admin.data[:browse_bot][:authorization]
			@admin.data[:browse_bot][:authorization][:auth_token] = request["auth_token"]
			@admin.data[:browse_bot][:authorization][:acquired] = DateTime.now
			@admin.save
			true
		else
			puts 'Error:'
			puts request
			false
		end
	end

	def self.authorize
		acquired = @admin.data[:browse_bot][:authorization][:acquired] unless @admin.data.dig(:browse_bot,:authorization,:auth_token).nil?
		if acquired
			unless acquired + 1.day > DateTime.now
				puts 'Bot authorization token was availiable but expired, acquiring new token.'
				self.acquire_auth_code
			else
				puts 'Bot authorization token availiable and valid.'
				true
			end
		else
			puts 'Bot authorization token was unavailiable, acquiring new token.'
			self.acquire_auth_code
		end
	end

	def self.acquire_yahoo_token_code
		if authorize
			payload = { id: @admin.id }
			response = HTTParty.post('https://api-browsebot.herokuapp.com/api/v1/yahoo_data/get_auth_code', 
				headers: {"Authorization" => 'Bearer ' + @admin.data[:browse_bot][:authorization][:auth_token]}, 
				body: payload).parsed_response
			unless response["error"]
				if response["results"]["auth_code"]
					@admin.collect_yahoo_token(response["results"]["auth_code"])
					puts 'Token Saved.'
					true
				elsif response["results"]["html"].include?("文字認証")
					puts 'Test to verify human...bot cannot continue'
					puts 'Manual login required'
					false
				else
					puts 'Unidentified Error.'
					ap response
					false
				end
			else
				puts 'Error:'
				ap response
				false
			end
		else
			puts 'Bot authorization error.'
			false
		end
	end

end