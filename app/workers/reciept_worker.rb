class RecieptWorker
	include Sidekiq::Worker

	def perform(options, message_id)

		def reciept(options)
			options[:oysis].to_i.zero? ? oysis = false : oysis = true
			if oysis
				unless options[:order_id].nil? || !options[:order_id].is_a?(Integer)
					options[:order_id].empty? ? order = nil : order = RManifest.find(options[:order_id]).new_orders_hash.reverse[options[:order_id].to_i]
				end
			else
				order = nil
			end
			!order.nil? ? (remarks = order[:remarks].scan(/(?<=\[メッセージ添付希望・他ご意見、ご要望がありましたらこちらまで:\]).*/m).first) : remarks = ''
			options[:title].nil? ? title = '様' : title = options[:title]
			options[:expense_name].empty? ? expense = 'お品代として' : expense = options[:expense_name]
			if options[:purchaser].empty?
				if order.nil?
					purchaser = ''
				else
					purchaser = order[:sender]["familyName"]
				end
			else
				purchaser = options[:purchaser]
			end
			if options[:amount].empty?
				if order.nil?
					amount = ''
				else
					amount = order[:final_cost]
				end
			else
				amount = options[:amount]
			end
			oyster_sisters_info = "株式会社船曳商店 　
			OYSTER SISTERS
			〒678-0232
			兵庫県赤穂市中広1576－11
			TEL: 0791-42-3645
			FAX: 0791-43-8151
			店舗運営責任者: 船曳　晶子"
			company_info = "株式会社船曳商店 　
			〒678-0232
			兵庫県赤穂市中広1576－11
			TEL: 0791-42-3645
			FAX: 0791-43-8151
			メール: info@funabiki.info
			ウエブ: www.funabiki.info"
			oyster_sisters_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/Oyster%20Sisters%202.jpg")
			oysis_logo_cell = {image: oyster_sisters_logo, :scale => 0.08, colspan: 1, rowspan: 3, :position  => :center, :vposition => :center}
			funabiki_logo = open("https://storage.googleapis.com/funabiki-online.appspot.com/logo_ns.png")
			logo_cell = {:image => funabiki_logo, :scale => 0.05, colspan: 1, rowspan: 3, :position  => :center, :vposition => :center }
			receipt_date = options[:sales_date]

			# Make the PDF
			Prawn::Document.generate("PDF.pdf", page_size: "A5", :margin => [15]) do |pdf|
				pdf.font_families.update(PrawnPDF.fonts)

				#set utf-8 japanese font
				pdf.font "TakaoPMincho"
				pdf.font_size 10
				pdf.move_down 10
				receipt_table = Array.new
				receipt_table << [{content: '   領   収   証   ', colspan: 3, size: 17, align: :center}]
				receipt_table << [{content: '<u>  ' + purchaser + '  ' + title + '  </u>' , colspan: 2, size: 14, align: :center}, {content: receipt_date, colspan: 1, size: 10, align: :center}]
				receipt_table << [{content: '★', size: 10, align: :center}, {content: '<font size="18">￥ ' + ApplicationController.helpers.yenify(amount) + '</font>', size: 10, align: :center}, {content: '★', size: 10, align: :center}]
				receipt_table << [{content: '但 ' + expense + '<br>上  記  正  に  領  収  い  た  し  ま  し  た', size: 10, align: :center, valign: :bottom, colspan: 3}]
				if oysis
					receipt_table << [{content: '内　　訳', colspan: 1}, oysis_logo_cell, {content: oyster_sisters_info, colspan: 1, rowspan: 3, size: 8}]
				else
					receipt_table << [{content: '内　　訳', colspan: 1}, logo_cell, {content: company_info, colspan: 1, rowspan: 3, size: 8}]
				end
				receipt_table << [{content: '税抜金額', colspan: 1}]
				receipt_table << [{content: '消費税額等（     ％）', colspan: 1}]

				2.times do |i|
					pdf.table(receipt_table, cell_style: {inline_format: true, valign: :center, padding: 10}, width: pdf.bounds.width, column_widths: {0..3 => (pdf.bounds.width/3)} ) do |t|
						t.cells.borders = [:top, :left, :right, :bottom]
						t.cells.border_width = 0
						t.row(0).border_top_width = 0.25
						t.row(-1).border_bottom_width = 0.25
						t.column(0).border_left_width = 0.25
						t.column(-1).border_right_width = 0.25

						t.row(1).border_top_width = 0.25
						t.row(1).border_bottom_width = 0.25
						t.row(2).border_bottom_width = 0.25
						t.row(2).border_lines = [:dotted, :solid, :dotted, :solid]
						t.row(1).border_lines = [:dotted, :solid, :dotted, :solid]

						t.row(2).background_color = 'EEEEEE'

						t.row(-2).column(0).border_bottom_width = 0.25
						t.row(-3).column(0).border_bottom_width = 0.25
						t.row(-2).column(0).border_lines = [:dotted, :solid, :dotted, :solid]
						t.row(-3).column(0).border_lines = [:dotted, :solid, :dotted, :solid]
					end
					i == 0 ? (pdf.move_down 40) : ()
				end
				oyster_sisters_logo.close
				funabiki_logo.close
				return pdf
			end
		end

		message = Message.find(message_id)
		pdf_data = reciept(eval(options).transform_keys{|k| k.to_sym})
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		pdf_data = nil
		pdf = nil
		GC.start
		message.update(state: true, message: '領収証作成完了。')

	end
end
