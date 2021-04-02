module OysterSuppliesHelper

	def type_to_japanese(type)
		japanese = {"large" => "むき身（大）", "small" => "むき身（小）", "eggy" => "むき身（卵）", "large_shells" => "殻付き（大）", "small_shells" => "殻付き（小）", "thin_shells" => "殻付き（バラ）"}
		japanese[type]
	end

	def type_to_unit(type)
		japanese = {"large" => "㎏", "small" => "㎏", "eggy" => "㎏", "large_shells" => "個", "small_shells" => "個", "thin_shells" => "㎏"}
		japanese[type]
	end

	def number_to_circular(num)
		conversion = {"1" => "①", "2" => "②", "3" => "③", "4" => "④", "5" => "⑤", "6" => "⑥", "7" => "⑦", "8" => "⑧", "9" => "⑨", "10" => "⑩", "11" => "⑪", "12" => "⑫", "13" => "⑬", "14" => "⑭", "15" => "⑮" }
		conversion[num] ? conversion[num] : ()
	end

	def kanji_am_pm(am_or_pm)
		conversion = { "am" => "午前", "pm" => "午後", "午前" => "am", "午後" => "pm" }
		conversion[am_or_pm] ? conversion[am_or_pm] : ()
	end

	def print_price_title(type)
		price = {"large" => "￥600 ~ ￥3000", "small" => "￥600 ~ ￥3000", "eggy" => "￥600 ~ ￥3000", "large_shells" => "￥30 ~ ￥100", "small_shells" => "￥30 ~ ￥100", "thin_shells" => "￥200 ~ ￥800"}
		price[type]
	end

	def stat_column_title(stat)
		{
			'grand_total' => '総合計',
			'hyogo_grand_total' => '兵庫県合計',
			'okayama_grand_total' => '岡山県合計',
			'kara_grand_total' => '殻付き合計',
		}[stat]
	end

	def get_supply_stat(stat, supply)
		{
			'grand_total' => supply.totals[:mukimi_total],
			'hyogo_grand_total' => supply.totals[:hyogo_total],
			'sakoshi_subtotal' => supply.totals[:sakoshi_muki_volume],
			'aioi_subtotal' => supply.totals[:aioi_muki_volume],
			'okayama_grand_total' => supply.totals[:okayama_total],
			'kara_grand_total' => supply.totals[:shell_total]
		}[stat]
	end

	def stat_hash(supplies)
		supplies.map{|supply| {date: supply.supply_date, data: supply.totals} }
	end

	def stat_key_to_japanese(key)
		{
			:okayama_total => '岡山県量合計(kg)', 
			:shell_total => '兵庫県殻付き合計(個)', 
			:big_shell_avg_cost => '兵庫県殻付き一個単価平均(¥)', 
			:sakoshi_eggy_volume => '坂越海域むきみ卵量(kg)',
			:sakoshi_small_volume => '坂越海域むきみ小量(kg)',
			:sakoshi_large_volume => '坂越海域むきみ大量(kg)',
			:sakoshi_muki_volume => '坂越全むき身量小計(kg)',
			:aioi_eggy_volume => '相生海域むきみ卵量(kg)',
			:aioi_small_volume => '相生海域むきみ小量(kg)',
			:aioi_large_volume => '相生海域むきみ大量(kg)',
			:aioi_muki_volume => '相生全むき身量小計(kg)',
			:sakoshi_eggy_cost => '坂越海域むき身卵経費小計(¥)',
			:sakoshi_small_cost => '坂越海域むき身小経費小計(¥)',
			:sakoshi_large_cost => '坂越海域むき身大経費小計(¥)',
			:sakoshi_muki_cost => '坂越海域全むき身経費小計(¥)',
			:sakoshi_avg_kilo => '坂越海域むき身キロ単価平均(¥)',
			:aioi_eggy_cost => '相生海域むき身卵経費小計(¥)',
			:aioi_small_cost => '相生海域むき身小経費小計(¥)',
			:aioi_large_cost => '相生海域むき身大経費小計(¥)',
			:aioi_muki_cost => '相生海域全むき身経費小計(¥)',
			:aioi_avg_kilo => '相生海域むき身キロ単価平均(¥)',
			:hyogo_total => '兵庫県むき身量合計(kg)', 
			:hyogo_mukimi_cost_total => '兵庫県むき身経費合計(¥)', 
			:hyogo_avg_kilo => '兵庫県むき身キロ単価平均(¥)', 
			:okayama_mukimi_cost_total => '岡山県むき身経費合計(¥)', 
			:okayama_avg_kilo => '岡山県むき身キロ単価平均(¥)', 
			:mukimi_total => '全むき身量合計(kg)', 
			:cost_total => '全むき身経費合計(¥)', 
			:total_kilo_avg => '全むき身キロ単価平均(¥)'
		}[key]
	end

	def stat_key_to_unit(key)
		stat_key_to_japanese(key)[/(?<=\().*(?=\))/]
	end

	def period_stats(stat_hash)
		stat_hash.inject({}) do |new_hash, supply|
			supply[:data].each do |key, int|
				if key.to_s.include?('avg')
					if int > 0
						new_hash[key].nil? ? new_hash[key] = [int] : new_hash[key] << int
					end
				else
					new_hash[key].nil? ? new_hash[key] = int : new_hash[key] += int
				end
			end
			new_hash
		end
	end

end
