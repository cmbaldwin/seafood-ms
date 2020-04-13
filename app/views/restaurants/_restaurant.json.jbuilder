json.extract! restaurant, :id, :namae, :company, :link, :address, :arrival_time, :products, :stats, :created_at, :updated_at
json.url restaurant_url(restaurant, format: :json)
