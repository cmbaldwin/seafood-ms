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
			'hyogo_grand_total' => supply.totals[:sakoshi_total],
			'okayama_grand_total' => supply.totals[:okayama_total],
			'kara_grand_total' => supply.totals[:shell_total],
		}[stat]
	end

end
