class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	before_action :authenticate_user!
	before_action :configure_permitted_parameters, if: :devise_controller?

	def authorize_admin
	    redirect_to :back, status: 401 unless current_user.admin
	end

	def fetch_chart
		chart_params = Rack::Utils.parse_nested_query(params[:chart_params]).deep_symbolize_keys
		chart_params[:init_params][:stacked] = (chart_params[:init_params][:stacked] == "true") if chart_params[:init_params][:stacked]
		@chart_params = chart_params
		respond_to do |format|
			format.js { render layout: false }
		end
	end

	def time_setup
		@today = DateTime.now.strftime('%Y年%m月%d日')
		@this_season_start = (Date.today.month < 10) ? Date.new((Date.today.year - 1), 10, 1) : Date.new(Date.today.year, 10, 1)
		@this_season_end = (Date.today.month < 10) ? Date.new(Date.today.year, 10, 1) : Date.new((Date.today.year + 1), 10, 1)
		@prior_season_start = (Date.today.month < 10) ? Date.new((Date.today.year - 2), 10, 1) : Date.new((Date.today.year - 1), 10, 1)
		@prior_season_end = (Date.today.month < 10) ? Date.new((Date.today.year - 1), 10, 1) : Date.new((Date.today.year), 10, 1)
	end

	def to_nengapi(datetime)
		datetime.strftime('%Y年%m月%d日')
	end

	def nengapi_maker(date, plus)
		(date + plus).strftime('%Y年%m月%d日')
	end

	def rakuten_check
		rakuten_api_client = RakutenAPI.new
		@rakuten_shinki = rakuten_api_client.get_details_by_ids(rakuten_api_client.get_unprocessed_shinki)
	end

	def wc_check
		@wc_shinki = WCAPI.new.shinki
	end

	protected

	def configure_permitted_parameters
		added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
		devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
		devise_parameter_sanitizer.permit :account_update, keys: added_attrs
	end

end
