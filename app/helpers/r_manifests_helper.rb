module RManifestsHelper

	def order_shipping_numbers_link(order)
		links = Hash.new
		order[:raw_data]["PackageModelList"].each do |package|
			family_name = package["SenderModel"]["familyName"]
			first_name = package["SenderModel"]["firstName"]
			recipient = family_name.to_s + " " + first_name.to_s
			package["ShippingModelList"].each_with_index do |box, i|
				shipping_number = box["shippingNumber"]
				if shipping_number
					links[recipient] = 'https://jizen.kuronekoyamato.co.jp/jizen/servlet/crjz.b.NQ0010?id=' + shipping_number
				else
					links[recipient + ' !'] = '#'
				end
			end
		end
		links
	end

	def recipients_alert(recipients)
		alert = false
		recipients.keys.each do |k|
			k.include?('!') ? (alert = true) : ()
		end
		alert
	end

	def order_link(order)
		'https://order-rp.rms.rakuten.co.jp/order-rb/individual-order-detail-sc/init?orderNumber=' + order[:raw_data]["orderNumber"]
	end

	def order_counts(r_manifest)[i]
		counts = Hash.new
		mizukiri_count = 0
		shells_count = 0
		dekapuri_count = 0
		anago_count = Array.new
		ebi_count = Array.new
		if !r_manifest.orders_hash.nil?
			r_manifest.orders_hash.each do |id, order_hash|
				if order_hash.is_a?(Hash)
					order_counts = order_hash[:order_count]
					#mizukiri & shells
					if order_hash[:mizukiri].length > 0
						order_hash[:mizukiri].each do |s|
							n = order_counts.shift.to_i
							mizukiri_count += s[/(?<=×)\d/].to_i * n
						end
					end
					if order_hash[:shells].length > 0
						order_hash[:shells].each do |s|
							n = order_counts.shift.to_i
							shells_count += s[/\d*(?=ヶ)/].to_i * n
						end
					end
					if order_hash[:sets].length > 0
						order_hash[:sets].each do |s|
							n = order_counts.shift.to_i
							mizukiri_count += s[/(?<=×)\d/].to_i * n
							shells_count += (Moji.zen_to_han(s))[/\d*(?=個)/].to_i * n
						end
					end
					#dekapuri  
					order_hash[:others].each do |s|
						dekapuri_count += s[/(?<=×)\d/].to_i
						anago = s[/(?<=穴子)\d*(g)/].to_s
						if anago != "" then anago_count << anago end
						ebi = s[/(干えび).*(袋)/].to_s
						if ebi != "" then ebi_count << ebi end
					end
				end
			end
		end
		counts[:mizukiri] = mizukiri_count
		counts[:shells] = shells_count
		counts[:dekapuri] = dekapuri_count
		counts[:anago] = anago_count
		counts[:ebi] = ebi_count
		counts
	end

	def today_warn(r_manifest)
		r_manifest.sales_date == Date.today.strftime("%Y年%m月%d日")
	end

	def key_to_counter(k)
		convert = {:mizukiri => 'パック', :shells => '個', :dekapuri => 'パック', :anago => '件', :ebi => '件'}
		convert[k]
	end

	def display_order_count(n)
		if n.to_i > 1
			('<span class="order_count float-right text-danger">').html_safe + n + ('</span>').html_safe
		end
	end

end
