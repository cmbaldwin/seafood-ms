class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true

	def yenify(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "")
	end

	def yenify_with_decimal(number)
		ActionController::Base.helpers.number_to_currency(number, locale: :ja, :unit => "", precision: 1)
	end

	def sales_date_to_datetime
		DateTime.strptime(self.sales_date, "%Y年%m月%d日")
	end

	def manufacture_date_to_datetime
		DateTime.strptime(self.manufacture_date, "%Y年%m月%d日")
	end

	def to_nengapi(datetime)
		datetime.strftime("%Y年%m月%d日")
	end

	def current_season_upto(datetime)
		#return array of dates between the start of the returned record's season and the date of the record
		start = (datetime.month < 10) ? DateTime.new((datetime.year - 1), 10, 1) : DateTime.new(datetime.year, 10, 1)
		(start..datetime).map {|d| to_nengapi(d)}
	end

end