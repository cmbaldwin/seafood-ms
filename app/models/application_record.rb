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

	def to_nengapi
		self.strftime("%Y年%m月%d日")
	end
end