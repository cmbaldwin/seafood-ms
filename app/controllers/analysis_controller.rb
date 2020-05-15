class AnalysisController < ApplicationController
	before_action :check_status
	
	def check_status
		return unless !current_user.admin?
		flash[:notice] = 'そのページはアクセスできません。'
		redirect_to root_path, error: 'そのページはアクセスできません。'
	end

	def index
		get_yearly_product_analysis
		@analysis = @yearly_company_totals
	end

	def get_yearly_product_analysis
		@yearly_product_totals = Hash.new
		@yearly_company_totals = Hash.new
		@yearly_associated_totals = Hash.new
		@restaurants = Restaurant.all.order(:company, :namae)
		associations = Product.all.pluck(:infomart_association, :id)
		@restaurants.each do |restaurant|
			if restaurant.stats && restaurant.stats[:totals]
				restaurant.stats[:totals].each do |year, products_hash|
					@yearly_product_totals[year].is_a?(Hash) ? () : @yearly_product_totals[year] = Hash.new
					@yearly_company_totals[year].is_a?(Hash) ? () : @yearly_company_totals[year] = Hash.new
					@yearly_associated_totals[year].is_a?(Hash) ? () : @yearly_associated_totals[year] = Hash.new
					@yearly_associated_totals[year][0].is_a?(Hash) ? () : @yearly_associated_totals[year][0] = Hash.new
					products_hash.each do |product_name, total|
						fixed_product_name = product_name.gsub(/\r\n軽減\r\n/,'').gsub(/\/ｃｓ/, '')
						@yearly_product_totals[year][fixed_product_name] ? @yearly_product_totals[year][fixed_product_name] += total : @yearly_product_totals[year][fixed_product_name] = total
						restaurant.company.nil? ? company = restaurant.namae : company = restaurant.company
						@yearly_company_totals[year][company].is_a?(Hash) ? () : @yearly_company_totals[year][company] = Hash.new
						@yearly_company_totals[year][company][fixed_product_name] ? @yearly_company_totals[year][company][fixed_product_name] += total : @yearly_company_totals[year][company][fixed_product_name] = total
						@yearly_company_totals[year][company] = @yearly_company_totals[year][company].sort_by {|k, v| v }.to_h
						found = false
						associations.each do |association|
							association_hash = association[0]
							associated_id = association[1]
							if association_hash
								association_hash.each do |assoc_product_name, count|
									unless found
										if product_name == assoc_product_name
											puts association
											associated_product_count = Product.find(associated_id).count
											@yearly_associated_totals[year][associated_id] ? (@yearly_associated_totals[year][associated_id] += (total * count.to_i * associated_product_count)) : (@yearly_associated_totals[year][associated_id] = (total * count.to_i * associated_product_count))
											found = true
										end
									end
								end
							end
						end
						unless found
							@yearly_associated_totals[year][0][product_name] ? (@yearly_associated_totals[year][0][product_name] += (total)) : (@yearly_associated_totals[year][0][product_name] = (total))
						end
					end
				end
			end
		end
	end

	def fetch_analysis
		params[:area] == 'product' ? get_yearly_product_analysis : ()
		@analysis = instance_variable_get("@#{params[:data]}")
		respond_to do |format|
			format.js { render layout: false }
		end
	end

end
