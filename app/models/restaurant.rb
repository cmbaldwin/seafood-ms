class Restaurant < ApplicationRecord
	has_many :restaurant_and_manifest_joins
	has_many :manifests, through: :restaurant_and_manifest_joins

	serialize :products
	serialize :stats
	validates_presence_of :namae
	validates_uniqueness_of :namae
	validates_uniqueness_of :link

	def get_link
		"https://www2.infomart.co.jp/seller/search/company_detail.page?19&mcd=" + self.link.to_s
	end

end
