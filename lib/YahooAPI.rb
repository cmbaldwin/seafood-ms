class YahooAPI
	include HTTParty
	# There are three required variables and two optional variables
	# ENV['YAHOO_PEM_FILE'] --PEM file name, located in the rails root directory
	# ENV['YAHOO_PEM_PASS'] --PEM file password (see: https://developer.yahoo.co.jp/webapi/shopping/help.html#orderapicertificate)
	# ENV["QUOTAGUARDSTATIC_URL"] --The URL of your proxy including user:password and port
	# ENV['YAHOO_CLIENT_ID'] --A Yahoo shopping API approved development client ID (requires application)
	# ENV['YAHOO_SECRET'] -- The above client's secret key

	# https://github.com/jnunemaker/httparty/blob/6f4d6ea4a2707a4f1466f45bf5c67556cdbed2b7/lib/httparty.rb#L322
	if ENV['YAHOO_PEM_FILE'] && ENV['YAHOO_PEM_PASS']
		pkcs12 File.read(Rails.root.to_s + '/' + ENV['YAHOO_PEM_FILE']), ENV['YAHOO_PEM_PASS']
	end

	# See https://github.com/jnunemaker/httparty/blob/6f4d6ea4a2707a4f1466f45bf5c67556cdbed2b7/lib/httparty.rb#L29
	# If you haven't set this enviornment variable the client will return an error
	@proxy = URI(ENV["QUOTAGUARDSTATIC_URL"])
	http_proxy @proxy.host, @proxy.port, @proxy.user, @proxy.password

	def initialize
		# We use the first user as a default because our first user is an admin
		(defined? current_user) ? (@user = current_user) : (@user = User.find(1)) 
		(@user.data[:yahoo] = Hash.new if @user.data[:yahoo] != nil) if @user
		@auth_header = {
			"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
			"Authorization" => 'Basic ' + (Base64.encode64(ENV['YAHOO_CLIENT_ID'] + ":"  + ENV['YAHOO_SECRET']).gsub(/\n/, ''))
		}
	end

	def proxy?
		self.class.get("http://ip.jsontest.com").parsed_response != HTTParty.get("http://ip.jsontest.com").parsed_response
	end

	def bot_token_attempt
		begin
			puts "Attempting automated token code acquisition."
			if BrowseBotAPI.acquire_yahoo_token_code
				@user.reload if @user
				true
			end
		rescue
			puts 'Error with BrowseBotAPI...Manual login required.'
			false
		end
	end

	def login_code?
		@user.reload
		if defined? @user.data[:yahoo][:login_token_code][:acquired]
			puts 'Login token code found.'
			if @user.data[:yahoo][:login_token_code][:acquired] + 10.minutes > DateTime.now
				puts 'Login token code not expired.'
				true
			else
				puts 'Login token code expired'
				false
			end
		else
			puts 'No login token code.'
			false
		end
	end

	def refresh_token?
		@user.reload
		if defined? @user.data[:yahoo][:authorization]["refresh_token"]
			puts 'Authorization refresh token found.'
			if (@user.data[:yahoo][:authorization][:acquired] + 59.minutes) > DateTime.now
				puts 'Authorization refresh token not expired.'
				true
			else 
				puts 'Authorization refresh token expired.'
				false
			end
		else 
			puts 'No authorization refresh token availiable.'
			false
		end
	end

	def authorized?
		@user.reload
		if defined? @user.data[:yahoo][:authorization][:acquired]
			puts 'Authorized to access API.'
			(@user.data[:yahoo][:authorization][:acquired] + 59.minutes) > DateTime.now
		else
			false
		end
	end

	def save_auth_token(response)
		@user.data[:yahoo][:authorization] = Hash.new
		@user.data[:yahoo][:authorization] = response
		@user.data[:yahoo][:authorization][:acquired] = DateTime.now
		puts "Access acquired for #{@user.data[:yahoo][:authorization]["expires_in"]} seconds.'" if @user.save
		@user.reload
	end

	def acquire_auth_token
		# https://developer.yahoo.co.jp/yconnect/v1/server_app/explicit/token.html
		if login_code?
			begin
				puts 'Acquiring authorization access token using temporary login token code'
				body = { 
						"grant_type" => "authorization_code",
						"code" => @user.data[:yahoo][:login_token_code][:token_code],
						"redirect_uri" => "https://www.funabiki.online/yahoo/"
						}
				request = self.class.post('https://auth.login.yahoo.co.jp/yconnect/v1/token', headers: @auth_header, body: body)
				puts 'Success, Authorization Token Saved.' if save_auth_token(request.parsed_response)
			rescue TypeError
				puts 'Error with Yahoo API request:'
				ap request.parsed_response if request
			end
		elsif refresh_token?
			begin
				puts 'Refreshing authorization access token'
				body = { 
							"grant_type" => "refresh_token",
							"refresh_token" => @user.data[:yahoo][:authorization]["refresh_token"]
							}
				request = self.class.post("https://auth.login.yahoo.co.jp/yconnect/v1/token", :headers => @auth_header, body: body)
				save_auth_token(request.parsed_response)
			rescue TypeError
				puts 'Error with Yahoo API request:'
				ap request.parsed_response if request
			end
		else
			puts 'No login code or refresh token.'
		end
	end

	def get_status
		# https://developer.yahoo.co.jp/webapi/shopping/orderCount.html
		if authorized?
			begin
				request = self.class.get("https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderCount?sellerId=oystersisters",
					:headers => {"Content-Type" => 'text/xml;charset=UTF-8',
						"Authorization" => 'Bearer ' + @user.data[:yahoo][:authorization]["access_token"]})
				@user.data[:yahoo] = Hash.new unless !@user.data[:yahoo].nil?
				@user.data[:yahoo][:store_status] = Hash.new
				@user.data[:yahoo][:store_status][:status] = request.parsed_response
				@user.data[:yahoo][:store_status][:acquired] = DateTime.now
				@user.save
				true
			rescue TypeError
				puts "Error with Yahoo API request:"
				ap request.parsed_response if request
				false
			end
		else
			puts 'No authorization, login required.'
			false
		end
	end

	def get_new_orders(period = 2.weeks)
		if authorized?
			begin
				request = self.class.post("https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderList",
					:headers => {"Content-Type" => 'text/xml;charset=UTF-8',
						"Authorization" => 'Bearer ' + @user.data[:yahoo][:authorization]["access_token"]},
					:body => 
						"<Req>
							<Search>
								<Condition>
								<OrderStatus>1,2,3,4,5</OrderStatus>
								<OrderTimeFrom>" + (DateTime.now - period).strftime("%Y%m%d") + "000000" + "</OrderTimeFrom>
								<OrderTimeTo>" + DateTime.now.strftime("%Y%m%d%H%M%S") + "</OrderTimeTo>
								</Condition>
								<Field>OrderTime,OrderId,DeviceType,IsRoyalty,IsAffiliate,OrderStatus,StoreStatus,IsReadOnly,IsActive,IsSeen,IsSplit,Suspect,IsRoyaltyFix,PayStatus,SettleStatus,PayType,PayMethod,NeedBillSlip,NeedDetailedSlip,NeedReceipt,BillFirstName,BillFirstNameKana,BillLastName,BillLastNameKana,BillPrefecture,ShipFirstName,ShipFirstNameKana,ShipLastName,ShipLastNameKana,ShipPrefecture,ShipStatus,ShipMethod,ShipRequestDateNo,ShipCompanyCode,BuyerCommentsFlag,ReleaseDateFrom,ReleaseDateTo,GetPointFixDateFrom,GetPointFixDateTo,UsePointFixDateFrom,UsePointFixDateTo,IsLogin,TotalPrice</Field>
							</Search>
							<SellerId>oystersisters</SellerId>
						</Req>")
				response = request.parsed_response["Result"]["Search"]["OrderInfo"]
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
			rescue TypeError
				puts "Error with Yahoo API request:"
				ap request.parsed_response if request
				false
			end
		else
			puts 'No authorization, login required.'
			false
		end
	end

	def record_results(compiled_results)
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

	def get_order_details(order_id_array)
		# https://developer.yahoo.co.jp/webapi/shopping/orderInfo.html
		if authorized?
			begin
				all_order_details = Hash.new
				order_id_array.each do |order_id|
					order_details = self.class.post("https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderInfo",
						:headers => {"Content-Type" => 'text/xml;charset=UTF-8',
							"Authorization" => 'Bearer ' + @user.data[:yahoo][:authorization]["access_token"]},
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
			rescue TypeError
				puts "Error with Yahoo API request:"
				ap request.parsed_response if request
				false
			end
		else
			puts 'No authorization, login required.'
			false
		end
	end

end