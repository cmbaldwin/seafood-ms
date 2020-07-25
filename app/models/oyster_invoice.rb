class OysterInvoice < ApplicationRecord
	has_many :oyster_invoices_supply
	has_many :oyster_supplies, through: :oyster_invoices_supply, validate: false

	mount_uploader :aioi_all_pdf, OysterInvoiceUploader
	mount_uploader :aioi_seperated_pdf, OysterInvoiceUploader
	mount_uploader :sakoshi_all_pdf, OysterInvoiceUploader
	mount_uploader :sakoshi_seperated_pdf, OysterInvoiceUploader

	validates_presence_of :start_date
	validates_uniqueness_of :start_date
	validates_presence_of :end_date
	validates_uniqueness_of :end_date
	validate :supply_uniqueness_and_completion, on: :create

	serialize :data, Hash

	attr_accessor :location
	attr_accessor :start_date_str
	attr_accessor :end_date_str
	attr_accessor :export_format
	attr_accessor :emails

	def supply_uniqueness_and_completion
		used_supply_ids = OysterInvoice.all.map {|i| i.oyster_supplies.ids }.flatten
		new_ids = self.date_range.map { |date| (supply = OysterSupply.find_by(supply_date: (date.strftime('%Y年%m月%d日')))) ? (supply.id) : () }.compact
		if new_ids.map {|id| used_supply_ids.include?(id)}.include?(true)
			self.errors.add(:base, "同じ日の仕切りがありました。")
		end
		if new_ids.map {|id| OysterSupply.find(id).check_completion.empty? ? (true) : (false) }.include?(false)
			self.errors.add(:base, "選択した仕切りは完成されていない。単価を入力してください。")
		end
	end

	def date_range
		start_date = Date.parse(self.start_date)
		end_date = Date.parse(self.end_date) - 1.day
		start_date..end_date
	end

	def self.search(id)
		if id
			where(id: id).order(start_date: :desc)
		else
			order(start_date: :desc)
		end
	end

end
