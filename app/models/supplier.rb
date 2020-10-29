class Supplier < ApplicationRecord
	enum location: [:坂越, :相生, :玉津, :邑久, :伊里, :日生]
	after_initialize :set_default_location, :if => :new_record?
	def set_default_location
		self.location ||= :坂越
	end

	validates_presence_of :company_name
	validates_uniqueness_of :company_name
end