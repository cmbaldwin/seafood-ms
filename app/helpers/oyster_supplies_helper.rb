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

end
