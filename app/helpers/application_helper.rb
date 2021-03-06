module ApplicationHelper

	def get_messages
		Message.where(user: current_user.id).order(:created_at).reverse.last(10)
	end

	def print_model(model)
		{
			'oyster_supply' => '牡蠣原料',
			'profit' => '計算表',
			'manifest' => 'Infomart/Funabiki.infoの出荷表',
			'rakuten_manifest' => '楽天出荷表',
			'yahoo_shipping_list' => 'ヤフー出荷表',
			'infomart_shipping_list' => 'Infomart出荷表',
			'online_orders_shipping_list' => 'Funabiki.info出荷表',
			'oyster_invoice' => '牡蠣原料仕切り',
			'update_yahoo' => 'ヤフーショッピングデータ更新',
			'reciept' => '領収証',
			'noshi' => '熨斗'
		}[model]
	end

	def print_message_data(message)
		def invoice_location(location)
			location == "sakoshi" ? ('坂越') : ('相生')
		end
		def invoice_format(eformat)
			eformat == "all" ? ('生産者まとめ') : ('各生産者')
		end
		data = message.data
		if message.model == 'oyster_invoice'
			if message.state
				unless data[:invoice_id] == 0
					begin
						invoice = OysterInvoice.find(data[:invoice_id])
						start_nengapi = Date.parse(invoice.start_date).strftime("%Y年%m月%d日")
						end_nengapi = Date.parse(invoice.end_date).strftime("%Y年%m月%d日")
						render html: (link_to("#{start_nengapi}~#{end_nengapi}仕切り", invoice, class: 'card-link')).html_safe
					rescue ActiveRecord::RecordNotFound
						render html: ("<p class='small text-warning'>エラー:　仕切り##{data[:invoice_id]}をみつけられませんでした。</p>").html_safe
					end
				else
					render html: (link_to("#{data[:invoice_preview][:start_date]}~の#{data[:invoice_preview][:end_date]}
						(#{invoice_location(data[:invoice_preview][:location])}-#{invoice_format(data[:invoice_preview][:export_format])})
						仕切りプレビュー", message.document.url, class: 'card-link', target: '_blank')).html_safe
				end
			end
		elsif message.model == 'oyster_supply'
			if message.state
				begin
					oyster_supply = OysterSupply.find(data[:oyster_supply_id])
					render html: (link_to("#{oyster_supply.supply_date}原料受入れチェック表", message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　原料受入れ##{data[:oyster_supply_id]}をみつけられませんでした。</p>").html_safe
				end
			end
		elsif message.model == 'rakuten_manifest'
			if message.state
				begin
					@r_manifest = RManifest.find(data[:r_manifest_id])
					render html: (link_to("楽天#{'とヤフー' if data[:include_yahoo]}#{' 商品分別版 ' if data[:seperated]}出荷表（#{@r_manifest.sales_date})", message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　出荷表##{data[:oyster_supply_id]}をみつけられませんでした。</p>").html_safe
				end
			end
		elsif message.model == 'manifest'
			if message.state
				begin
					@manifest = Manifest.find(data[:manifest_id])
					render html: (link_to("InfoMart/Funabiki.infoの出荷表（#{@manifest.sales_date})", message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　出荷表##{data[:oyster_supply_id]}をみつけられませんでした。</p>").html_safe
				end
			end
		elsif message.model == 'infomart_shipping_list'
			if message.state
				begin
					render html: (link_to("Infomart出荷表（#{message.data[:ship_date]})", message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　出荷表##{data[:oyster_supply_id]}をみつけられませんでした。</p>").html_safe
				end
			end
		elsif message.model == 'online_orders_shipping_list'
			if message.state
				begin
					render html: (link_to("Funabiki.info出荷表（#{message.data[:ship_date]})", message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　出荷表##{data[:oyster_supply_id]}をみつけられませんでした。</p>").html_safe
				end
			end
		elsif message.model == 'yahoo_shipping_list'
			if message.state
				begin
					render html: (link_to("ヤフー出荷表（#{message.data[:ship_date]})", message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　出荷表##{data[:oyster_supply_id]}をみつけられませんでした。</p>").html_safe
				end
			end
		elsif message.model == 'reciept'
			if message.state
				begin
					render html: (link_to(message.document.filename, message.document.url, class: 'card-link', target: '_blank')).html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　領収証保存出来なかった").html_safe
				end
			end
		elsif message.model == 'noshi'
			if message.state
				begin
					@noshi = Noshi.find(data[:noshi_id])
					render html: (link_to image_tag(@noshi.image_url(:thumb).to_s, :alt => "#{@noshi.namae.to_s + " " + @noshi.omotegaki.to_s}", :class => "noshi_img"), @noshi.image_url, target: "_blank").html_safe
				rescue
					render html: ("<p class='small text-warning'>エラー:　熨斗保存出来なかった").html_safe
				end
			end
		elsif message.model == 'update_yahoo'
			if message.state
				begin
					render html: ("").html_safe #placeholder in case we want to put something here, like data about the updated yahoo orders
				rescue
					render html: ("<p class='small text-warning'>エラー:　管理者へ連絡してください。</p>").html_safe
				end
			end
		else
			p 'error:'
			ap data.to_s
		end
	end

	def create_chart(chart_params)
		(method(chart_params[:chart_type]).call method(chart_params[:chart_path] + "_path").call, chart_params[:init_params])
	end

	def exp_card_popover(expiration_card)
		"<small>
			<div class='container m-0 p-0'>
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>名称</div>
					<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.product_name}</div>
				</div>
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>加工所所在地</div>
					<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.manufacturer_address}</div>
				</div>
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>加工者</div>
					<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.manufacturer}</div>
				</div>
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>採取海域</div>
					<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.ingredient_source}</div>
				</div>
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>用途</div>
					<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.consumption_restrictions}</div>
				</div>
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>保存温度</div>
					<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.storage_recommendation}</div>
				</div>
				#{if expiration_card.made_on
					"<div class='row m-0 p-0'>
						<div class='float-left w-25 font-weight-bolder m-0 p-0 border-bottom'>保存温度</div>
						<div class='float-right w-75 m-0 p-0 pl-2 border-bottom'>#{expiration_card.manufactuered_date}</div>
					</div>"
				end}
				<div class='row m-0 p-0'>
					<div class='float-left w-25 font-weight-bolder m-0 p-0'>#{expiration_card.print_shomiorhi}</div>
					<div class='float-right w-75 m-0 mb-2 p-0 pl-2'>#{expiration_card.expiration_date}</div>
				</div>
			</div>
		</small>"
	end

	def title(page_title)
		content_for(:title) { page_title }
	end

	def weekday_japanese(num)
		#d.strftime("%w") to Japanese
		weekdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
		weekdays[num]
	end

	def to_nengapi(date)
		date.strftime("%Y年%m月%d日")
	end

	def to_nengapiyoubi(date)
		date.strftime("%Y年%m月%d日 (#{weekday_japanese(date.wday)})")
	end

	def to_nengapijibun(date)
		date.strftime("%Y年%m月%d日%H時%M分")
	end

	def to_jibun(date)
		date.strftime("%H時%M分")
	end

	def yenify(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "")
	end

	def yenify_with_decimal(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "", precision: 1)
	end

	def cycle_table_rows
		cycle("even", "odd")
	end

	def nengapi_today
		Date.today.strftime('%Y年%m月%d日')
	end

	def nengapi_today_plus(number)
		(Date.today + number).strftime('%Y年%m月%d日')
	end

	def icon(icon, options = {})
		icon_path = "#{Rails.root}/node_modules/bootstrap-icons/icons/#{icon}.svg"
		backup_path = "#{Rails.root}/node_modules/bootstrap-icons/icons/x.svg"
		file = File.exist?(icon_path) ? File.read(icon_path) : File.read(backup_path)
		doc = Nokogiri::HTML::DocumentFragment.parse file
		svg = doc.at_css 'svg'
		if options[:class].present?
			svg['class'] += " " + options[:class]
		end
		if options[:tooltip].present?
			#data-toggle="tooltip" data-placement="top" title="Tooltip on top"
			svg['data-toggle'] += "tooltip"
		end
		doc.to_html.html_safe
	end

	def get_infomart_backend_link(backend_id)
		'https://www2.infomart.co.jp/trade/trade_detail.page?14&tid=' + backend_id + '&del_hf=1&through_status_code&returned_flg'
	end

	def online_order_counts(orders)
		counts = Hash.new
		types_arr = %w{生むき身 生セル 小殻付 セルカード 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(100g) 干し殻付エビ(100g) タコ}
		types_arr.each {|w| counts[w] = 0}
		orders.each do |order|
			unless order.cancelled
				order.counts.each_with_index do |count, i|
					counts[types_arr[i]] += count
				end
			end
		end
		cards = counts.values[3]
		anago = counts.values[7]
		results = {headers: counts.keys, values: counts.values, anago: anago, cards: cards}
		["セルカード", "穴子(g)"].each do |t|
			i = results[:headers].index(t)
			[:headers, :values].each {|k| results[k].delete_at(i)}
		end
		results
	end

	def yahoo_knife_counts(orders)
		orders.map{|o| o.knife_count unless (o.order_status(false) == 4 || o.item_ids.nil?)}.sum
	end

	def yahoo_order_counts(orders)
		counts = Hash.new
		types_arr = %w{生むき身 生セル 小殻付 セルカード 冷凍むき身 冷凍セル 穴子(件) 穴子(g) 干しムキエビ(80g) 干し殻付エビ(80g) タコ}
		types_arr.each {|w| counts[w] = 0}
		count_hash = {
			"kakiset302" => [2, 30, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset202" => [2, 20, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset301" => [1, 30, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset201" => [1, 20, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"kakiset101" => [1, 10, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki100" => [0, 100, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki50" => [0, 50, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki40" => [0, 40, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki30" => [0, 30, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki20" => [0, 20, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"karatsuki10" => [0, 10, 0, 1, 0, 0, 0, 0, 0, 0, 0],
			"mukimi04" => [4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"mukimi03" => [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"mukimi02" => [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"mukimi01" => [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			"pkara100" => [0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0],
			"pkara50" => [0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0],
			"pkara40" => [0, 0, 0, 0, 0, 40, 0, 0, 0, 0],
			"pkara30" => [0, 0, 0, 0, 0, 30, 0, 0, 0, 0, 0],
			"pkara20" => [0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0],
			"pkara10" => [0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0],
			"pmuki04" => [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
			"pmuki03" => [0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0],
			"pmuki02" => [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0],
			"pmuki01" => [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
			"tako1k" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			"mebi80x5" => [0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0],
			"mebi80x3" => [0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
			"hebi80x10" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0],
			"hebi80x5" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0],
			"anago600" => [0, 0, 0, 0, 0, 0, 1, 600, 0, 0, 0],
			"anago480" => [0, 0, 0, 0, 0, 0, 1, 480, 0, 0, 0],
			"anago350" => [0, 0, 0, 0, 0, 0, 1, 350, 0, 0, 0],
			"syoukara1kg" => [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
			"syoukara2kg" => [0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0],
			"syoukara3kg" => [0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0],
			"syoukara5kg" => [0, 0, 5, 1, 0, 0, 0, 0, 0, 0, 0]}
		orders.each do |order|
			unless order.order_status(false) == 4 || order.item_ids.nil? #unless cancelled or no item ids
				order.item_ids.each do |item_id|
					count_hash[item_id].each_with_index do |count, i|
						counts[types_arr[i]] += count
					end
				end
			end
		end
		cards = counts.values[3]
		anago = counts.values[7]
		results = {headers: counts.keys, values: counts.values, anago: anago, cards: cards}
		["セルカード", "穴子(g)"].each do |t|
			i = results[:headers].index(t)
			[:headers, :values].each {|k| results[k].delete_at(i)}
		end
		results
	end

	def online_order_counts_counter(i)
		["パック","個","kg","枚","パック","個","件","g","パック","パック","件",][i]
	end

	def online_order_knives(orders)
		orders.map{|o| o.knife }.sum
	end

	def online_order_noshis(orders)
		orders.map{|o| o.noshi }.sum
	end

end
