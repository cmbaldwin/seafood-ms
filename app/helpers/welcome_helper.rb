module WelcomeHelper

	def chart_min(chart)
		(chart.min_by { |k, v| v })[1]
	end
	def chart_max(chart)
		(chart.max_by { |k, v| v })[1]
	end

	def card_link(card, title, add_class)
		if card
			link_to title, card.download.url, class: 'btn ' + add_class, target: '_blank'
		else
			link_to title, new_expiration_card_path, class: 'btn disabled ' + add_class, target: '_blank'
		end
	end

	def print_frozen_product_name(product_id)
		namae = Product.find(product_id).namae
		idx = namae.index('(') || idx = namae.index('（')
		if !idx.nil?
			namae = namae.insert(idx, '<br>')
		end
		namae.html_safe
	end

	def frozen_packs_to_boxes(product_id, value)
		if !Product.find(product_id).namae.include?("セル")
			((value.to_i / 20).to_s + '箱 +' + (value.to_i % 20).to_s + '個<br><small>（' + value.round(0).to_s + '）</small>').html_safe
		else
			(value.to_s + '箱<br><small>（' + (value * 100).round(0).to_s + '）</small>').html_safe
		end
	end

	def rakuten_item_id_to_nickname(manageNumber)
		{"10000017" => "干えび(ムキ) 80g×5袋",
		"10000016" => "干えび(ムキ) 80g×3袋",
		"10000011" => "干えび(ムキ) 80g×10袋",
		"10000010" => "干えび(殻付) 80g×5袋",
		"boiltako800-1k" => "ボイルたこ (800g-1k)",
		"10000014" => "焼穴子 600g入",
		"10000013" => "焼穴子 480g入",
		"10000012" => "焼穴子 350g入",
		"10000018" => "生牡蠣むき身500g×1",
		"10000001" => "生牡蠣むき身500g×2",
		"10000035" => "生牡蠣むき身500g×2 (タイムセール)",
		"10000002" => "生牡蠣むき身500g×3",
		"10000003" => "生牡蠣むき身500g×4",
		"10000007" => "坂越牡蠣むき身500g×1 + 殻付10個セット",
		"10000008" => "坂越牡蠣むき身500g×1 + 殻付20個セット",
		"10000022" => "坂越牡蠣むき身500g×1 + 殻付30個セット",
		"10000009" => "坂越牡蠣むき身500g×2 + 殻付20個セット",
		"10000023" => "坂越牡蠣むき身500g×2 + 殻付30個セット",
		"10000031" => "冷凍殻付牡蠣10個",
		"10000037" => "冷凍殻付牡蠣20個",
		"10000038" => "冷凍殻付牡蠣30個",
		"10000039" => "冷凍殻付牡蠣40個",
		"10000041" => "冷凍殻付牡蠣50個",
		"10000042" => "冷凍殻付牡蠣100個",
		"10000027" => "冷凍むき身500g×1",
		"10000030" => "冷凍むき身500g×2",
		"10000028" => "冷凍むき身500g×3",
		"10000029" => "冷凍むき身500g×4",
		"10000015" => "殻付き 牡蠣10ヶ",
		"10000004" => "殻付き 牡蠣20ヶ",
		"10000005" => "殻付き 牡蠣30ヶ",
		"10000025" => "殻付き 牡蠣40ヶ",
		"10000006" => "殻付き 牡蠣50ヶ",
		"10000040" => "殻付き 牡蠣100ヶ"
		}[manageNumber]
	end

	def rakuten_order_link(id)
		'https://order-rp.rms.rakuten.co.jp/order-rb/individual-order-detail-sc/init?orderNumber=' + id
	end

	def rakuten_raw_oysters?(work_totals)
		[work_totals[:product_counts][:mizukiri].empty?,
		work_totals[:product_counts][:sets].empty?,
		work_totals[:product_counts][:shells].empty?].include?(false)
	end

end