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

end