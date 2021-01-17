class Noshi < ApplicationRecord

	validates_presence_of :ntype, :omotegaki

	mount_uploader :image, ImageUploader

	validates :namae,
		length: { maximum: 10 }
	validates :namae2,
		length: { maximum: 10 }
	validates :namae3,
		length: { maximum: 9 }
	validates :namae4,
		length: { maximum: 8 }
	validates :namae5,
		length: { maximum: 7 }

	def self.search(term)
		if term
			where('namae LIKE :search OR namae2 LIKE :search OR namae3 LIKE :search OR namae4 LIKE :search OR namae5 LIKE :search', search: "%#{term}%").order('id DESC')
		else
			order('id DESC')
		end
	end

end
