module ApplicationHelper

	def title(page_title)
		content_for(:title) { page_title }
	end

	def weekday_japanese(num)
		#d.strftime("%w") to Japanese
		weekdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
		weekdays[num]
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
		file = File.read("#{Rails.root}/node_modules/bootstrap-icons/icons/#{icon}.svg")
		doc = Nokogiri::HTML::DocumentFragment.parse file
		svg = doc.at_css 'svg'
		if options[:class].present?
			svg['class'] += " " + options[:class]
		end
		doc.to_html.html_safe
	end

end
