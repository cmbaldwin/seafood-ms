class ExpirationCard < ApplicationRecord

	mount_uploader :download, ShellCardUploader

	validates :product_name, uniqueness: {scope: [:manufacturer_address, :manufacturer, :ingredient_source, :storage_recommendation, :consumption_restrictions, :manufactuered_date, :expiration_date, :made_on, :shomiorhi]}

	def create_pdf
		pack_date = self.manufactuered_date
		use_by_date = self.expiration_date
		manufactured_only = self.made_on ? '（製造日なし）' : ''
		filename = self.product_name + '-' + pack_date + '-' + use_by_date + manufactured_only + "-カード.pdf"
		Prawn::Document.generate(filename, :page_size => "A4", :margin => [15]) do |pdf|
			#document set up
			pdf.font_families.update(PrawnPDF.fonts)
			#set utf-8 japanese font
			pdf.font "MPLUS1p"

			#first page for raw oysters
			#print the date
			pdf.font_size 9

			shell_card = Array.new
			shell_card << [' 名                     称', '<b>' + self.product_name + '</b>']
			shell_card << [' 加工 所 所 在地', self.manufacturer_address]
			shell_card << [' 加        工        者', self.manufacturer]
			shell_card << [' 採    取    海    域', self.ingredient_source]
			shell_card << [' 用                     途', self.consumption_restrictions]
			shell_card << [' 保    存    温    度', self.storage_recommendation]
			if self.made_on
				shell_card << [' 製  造  年  月  日', {:content => pack_date, :align => :center}]
			end
			shell_card << [self.print_shomiorhi, {:content => use_by_date, :align => :center}]
			one_shell_card = pdf.make_table( shell_card, :cell_style => {:border_width => 0.25, :valign => :center, :inline_format => true, :padding => 4, :height => 17}, :width => (pdf.bounds.width / 2 - 25), :column_widths => {0 => 75 } )
			cards = Array.new
			cards << [' ', ' ']
			5.times do
				cards << [{:content => one_shell_card}, {:content => one_shell_card}]
				cards << [' ', ' ']
			end
			pdf.table(cards, :cell_style => {:border_width => 0, :valign => :center, :padding => 0}, :width => pdf.bounds.width ) do |t|
				t.column(1).padding = [0,0,0,25]
				t.column(0).padding = [0,0,0,7]
				t.cells.style do |c|
					c.height = ((c.row) % 2).zero? ? 30 : ()
				end
				t.row(0).height = 5
				t.row(-1).height = 0
			end
			self.download = CarrierStringECIO.new(pdf.render)
		end
		pdf = nil
	end

	def print_shomiorhi
		self.shomiorhi ? ' 消    費    期    限' : ' 賞    味    期    限'
	end

	def shomiorhi_string
		self.shomiorhi ? '消費期限' : '賞味期限'
	end

end
