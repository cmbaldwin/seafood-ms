module SuppliersHelper

	def aioi_secondary(supplier)
		if supplier.location == "相生" then 'bg-light' end
	end

	def tax
		(((@oyster_supply.oysters["tax"].to_f - 1) * 100)).to_i.to_s + "%"
	end

	def type_to_kana(type)
		keys = Hash.new
		keys = { "large" => "むき身（大）", "small" => "むき身（小）", "eggy" => "むき身（卵）", "large_shells" => "殻付き〔大-個〕", "small_shells" => "殻付き〔小-個〕", "thin_shells" => "殻付き〔バラ-㎏〕" }
		keys[type]
	end
end
