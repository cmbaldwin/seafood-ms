module InfomartOrdersHelper

	def print_destination(order)
		order.destination[/.*(?=\（)/]
	end

	def food?(item)
		(item[:name].include?('箱代') || item[:name].include?('送料')) ? false : true	
	end

	def cold?(item)
		item[:name].include?('冷') ? true : false	
	end

	def status_badge_color(order)
		{
			"発注済" => "badge-warning",
			"発送済" => "badge-primary",
			"受領" => "badge-success",
			"ｷｬﾝｾﾙ(取引)" => "badge-danger"
		}[order.status]
	end

	def counts(order_relations)
		order_relations.map{|order| order.counts unless order.cancelled }.inject([0,0,0,0,0,0,0,0]){|m,c| c.each_with_index{|v,i| m[i] += v} unless c.nil?; m }
	end

	def count_title(i)
		# [ nama_500, nama_1k, nama_shell, frz_l, frz_ll, frz_nama, frz_shell, jp_shell ]
		[ "生むき身 500g", "生むき身 1k", "生殻付き牡蠣", "デカプリ 500g", "デカプリ 500g (LL)", "デカプリ 500g  (岡山 LL)", "冷凍殻付き牡蠣（100個単位）", "小 冷凍殻付き牡蠣（120個単位）", ][i]
	end

	def count_counter(i)
		[ "パック", "円盤", "個", "パック", "パック", "パック", "ケース", "ケース", ][i]
	end

end
