class RestaurantAndManifestJoin < ApplicationRecord
	belongs_to :restaurant, touch: true
	belongs_to :manifest, touch: true
end
