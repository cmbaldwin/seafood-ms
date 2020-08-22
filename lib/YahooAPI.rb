class YahooAPI
	include HTTParty
	if ENV['YAHOO_PEM_FILE'] && ENV['YAHOO_PEM_PASS']
		# PEM Certificate file https://developer.yahoo.co.jp/webapi/shopping/help.html#orderapicertificate
		# https://github.com/jnunemaker/httparty/blob/6f4d6ea4a2707a4f1466f45bf5c67556cdbed2b7/lib/httparty.rb#L322
		pkcs12 File.read(Rails.root.to_s + '/' + ENV['YAHOO_PEM_FILE']), ENV['YAHOO_PEM_PASS']
		puts 'SSL Certificate availiable'
	end
	if ENV["QUOTAGUARDSTATIC_URL"]
		# see https://github.com/jnunemaker/httparty/blob/6f4d6ea4a2707a4f1466f45bf5c67556cdbed2b7/lib/httparty.rb#L29
		@proxy = URI(ENV["QUOTAGUARDSTATIC_URL"])
		puts 'Proxy availiable'
	end

    # Admin (should be first user) holds the settings for Yahoo automation
	@admin = User.find(1)

	# https://developer.yahoo.co.jp/yconnect/v1/server_app/explicit/authorization.html (must be done manually)
	authorization = Base64.encode64(ENV['YAHOO_CLIENT_ID'] + ":"  + ENV['YAHOO_SECRET']).gsub(/\n/, '')
	
	@headers = {"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
				"Authorization" => 'Basic ' + authorization}

	def self.test_proxy
		puts HTTParty.get("http://ip.jsontest.com", 
			http_proxyaddr: @proxy.host, http_proxyport: @proxy.port, http_proxyuser: @proxy.user, http_proxypass: @proxy.password).parsed_response
	end

	def self.get_token_code
		if BrowseBotAPI.acquire_yahoo_token_code
			@admin.reload
			true
		end
	end

	def self.acquire_auth_code
		puts 'Acquiring authorization access token'
		payload = { 
				"grant_type" => "authorization_code",
				# https://developer.yahoo.co.jp/yconnect/v1/server_app/explicit/token.html
				"code" => @admin.data[:yahoo][:token_code][:code],
				"redirect_uri" => "https://www.funabiki.online/yahoo/"
				}
		HTTParty.post('https://auth.login.yahoo.co.jp/yconnect/v1/token', headers: @headers, body: payload)
	end

	def self.refresh_auth_code
		puts 'Refreshing authorization access token'
		payload = { 
					"grant_type" => "refresh_token",
					"refresh_token" => @admin.data[:yahoo][:authorization_code]["refresh_token"]
					}
		HTTParty.post("https://auth.login.yahoo.co.jp/yconnect/v1/token", :headers => @headers, body: payload)
	end

	def self.get_access_token
		@admin.reload
		if @admin.data.dig(:yahoo, :authorization_code, "refresh_token") && ((@admin.data[:yahoo][:authorization_code][:acquired] + 59.minutes) > DateTime.now)
			@admin.data[:yahoo][:authorization_code] = refresh_auth_code.parsed_response
			@admin.data[:yahoo][:authorization_code][:acquired] = DateTime.now
			@admin.save
			puts 'Authorization token Refreshed. Usable for ' + @admin.data[:yahoo][:authorization_code]["expires_in"] + ' seconds.'
			@admin.reload
			true
		elsif (@admin.data.dig(:yahoo, :token_code, :code)) && (@admin.data.dig(:yahoo, :token_code, :acquired) ? ((@admin.data[:yahoo][:token_code][:acquired] + 10.minutes) > DateTime.now) : false )
			@admin.data[:yahoo][:authorization_code] = acquire_auth_code.parsed_response
			@admin.data[:yahoo][:authorization_code][:acquired] = DateTime.now
			@admin.save
			@admin.reload
			puts 'New Authorization token Acquired. Usable for ' + @admin.data[:yahoo][:authorization_code]["expires_in"] + ' seconds.'
			true
		else
			puts 'No Token Code or the token code usage window has expired, will attempt automation once.'
			if get_token_code
				puts 'Acquired token code via bot, acquring authorization token.'
				@admin.reload
				@admin.data[:yahoo][:authorization_code] = acquire_auth_code.parsed_response
				@admin.data[:yahoo][:authorization_code][:acquired] = DateTime.now
				@admin.save
				@admin.reload
				puts 'New Authorization token Acquired. Usable for ' + @admin.data[:yahoo][:authorization_code]["expires_in"] + ' seconds.'
				true
			else
				false
			end
		end
	end

	def self.access_token_valid?
		unless @admin.data.dig(:yahoo, :authorization_code, :acquired).nil?
			@admin.data[:yahoo][:authorization_code][:acquired] + 59.minutes > DateTime.now
		else
			false
		end
	end

	def self.check_token
		if access_token_valid?
			true
		else
			puts 'Yahoo access token invalid/expired, attemping to acquire new token.'
			get_access_token
		end
	end

	def self.get_store_status
		# https://developer.yahoo.co.jp/webapi/shopping/orderCount.html
		if check_token && !@proxy.nil?
			get_status = HTTParty.get("https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderCount?sellerId=oystersisters",
				http_proxyaddr: @proxy.host, http_proxyport: @proxy.port, http_proxyuser: @proxy.user, http_proxypass: @proxy.password,
				:headers => {"Content-Type" => 'text/xml;charset=UTF-8',
					"Authorization" => 'Bearer ' + @admin.data[:yahoo][:authorization_code]["access_token"]},
				)
			@admin.data[:yahoo] = Hash.new unless !@admin.data[:yahoo].nil?
			@admin.data[:yahoo][:store_status] = Hash.new
			@admin.data[:yahoo][:store_status][:status] = get_status.parsed_response
			@admin.data[:yahoo][:store_status][:acquired] = DateTime.now
			@admin.save
			true
		else
			!@proxy.nil? ? (puts 'API endpoint requires static IP') : (puts "Manual login required")
			false
		end
	end

	def self.get_new_orders(time_period = 1.week)
		# (https://developer.yahoo.co.jp/webapi/shopping/orderList.html)
		if check_token && !@proxy.nil?
			get_orders = HTTParty.post("https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderList",
				http_proxyaddr: @proxy.host, http_proxyport: @proxy.port, http_proxyuser: @proxy.user, http_proxypass: @proxy.password,
				:headers => {"Content-Type" => 'text/xml;charset=UTF-8',
					"Authorization" => 'Bearer ' + @admin.data[:yahoo][:authorization_code]["access_token"]},
				:body => 
					"<Req>
						<Search>
							<Condition>
							<OrderStatus>1,2,3,4,5</OrderStatus>
							<OrderTimeFrom>" + (DateTime.now - time_period).strftime("%Y%m%d") + "000000" + "</OrderTimeFrom>
							<OrderTimeTo>" + DateTime.now.strftime("%Y%m%d%H%M%S") + "</OrderTimeTo>
							</Condition>
							<Field>OrderTime,OrderId,DeviceType,IsRoyalty,IsAffiliate,OrderStatus,StoreStatus,IsReadOnly,IsActive,IsSeen,IsSplit,Suspect,IsRoyaltyFix,PayStatus,SettleStatus,PayType,PayMethod,NeedBillSlip,NeedDetailedSlip,NeedReceipt,BillFirstName,BillFirstNameKana,BillLastName,BillLastNameKana,BillPrefecture,ShipFirstName,ShipFirstNameKana,ShipLastName,ShipLastNameKana,ShipPrefecture,ShipStatus,ShipMethod,ShipRequestDateNo,ShipCompanyCode,BuyerCommentsFlag,ReleaseDateFrom,ReleaseDateTo,GetPointFixDateFrom,GetPointFixDateTo,UsePointFixDateFrom,UsePointFixDateTo,IsLogin,TotalPrice</Field>
						</Search>
						<SellerId>oystersisters</SellerId>
					</Req>")
			if (get_orders.parsed_response.dig("Error", "Code")) && get_orders.parsed_response["Error"]["Code"] == "px-04102"
				puts "Access token refresh required."
				@admin.data[:yahoo] = Hash.new
				@admin.save
				@admin.reload
				false
			elsif response = get_orders.parsed_response["Result"]["Search"]["OrderInfo"]
				order_ids = Hash.new
				if response[0].is_a?(Hash)
					response.each_with_index do |order_response, i|
						order_ids[i] = order_response["OrderId"]
					end
				else
					order_ids[0] = response["OrderId"]
				end
				puts 'Getting order item details.'
				if order_details_response = get_order_details(order_ids.values)
					puts 'Compiling and recording orders in the database.'
					compiled_results = Hash.new
					order_ids.each do |i, order_id|
						compiled_results[order_id] = Hash.new
						unless order_ids.length < 2
							compiled_results[order_id] = response[i].merge(order_details_response[order_id])
						else
							compiled_results[order_id] = response.merge(order_details_response[order_id])
						end
					end
					record_results(compiled_results)
				else
					puts 'Error with acquiring order item details.'
					false
				end
			else
				puts "Results unprocessible:"
				ap get_orders.parsed_response
				false
			end
		else
			!@proxy.nil? ? (puts 'API endpoint requires static IP') : (puts "Manual login required")
			false
		end
	end

	def self.record_results(compiled_results)
		compiled_results.each do |order_id, order_details|
			unless YahooOrder.exists?(order_id: order_id)
				@order = YahooOrder.create(order_id: order_id) 
			else
				@order = YahooOrder.find_by(order_id: order_id)
			end
			ship_date = order_details["ResultSet"]["Result"]["OrderInfo"]["Ship"]["ShipDate"]
			@order.ship_date = ship_date unless ship_date.nil?
			@order.details = order_details
			@order.save
		end
	end

	def self.get_order_details(order_id_array)
		# https://developer.yahoo.co.jp/webapi/shopping/orderInfo.html
		if check_token && !@proxy.nil?
			all_order_details = Hash.new
			order_id_array.each do |order_id|
				order_details = HTTParty.post("https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderInfo",
					http_proxyaddr: @proxy.host, http_proxyport: @proxy.port, http_proxyuser: @proxy.user, http_proxypass: @proxy.password,
					:headers => {"Content-Type" => 'text/xml;charset=UTF-8',
						"Authorization" => 'Bearer ' + @admin.data[:yahoo][:authorization_code]["access_token"]},
					:body => 
						"<Req>
							<Target>
								<OrderId>#{order_id}</OrderId>
								<Field>LineId,ItemId,Title,SubCode,SubCodeOption,ItemOption,ProductId,Quantity,BillPhoneNumber,BillZipCode,BillPrefecture,BillPrefectureKana,BillCity,BillCityKana,BillAddress1,BillAddress1Kana,BillAddress2,BillAddress2Kana,BillPhoneNumber,PayMethod,PayMethodName,ShipMethod,ShipMethodName,ShipRequestDate,ShipRequestTime,ShipRequestTimeZoneCode,ArriveType,ShipDate,ShipZipCode,ShipPrefecture,ShipPrefectureKana,ShipCity,ShipCityKana,ShipAddress1,ShipAddress1Kana,ShipAddress2,ShipAddress2Kana,ShipPhoneNumber,ShipEmgPhoneNumber,ShipSection1Field,ShipSection1Value,ShipSection2Field,ShipSection2Value</Field>
								</Target>
							<SellerId>oystersisters</SellerId>
						</Req>").parsed_response
				all_order_details[order_id] = order_details
			end
			all_order_details
		else
			!@proxy.nil? ? (puts 'API endpoint requires static IP') : (puts "Manual login required")
			false
		end
	end

end