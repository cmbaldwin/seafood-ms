class Article < ApplicationRecord
	has_many :comments, dependent: :destroy
	belongs_to :user
	belongs_to :category

	validates :title, 
		presence: true,
		length: { minimum: 1 }
	validates :text, 
		presence: true,
		length: { minimum: 1 }
end
