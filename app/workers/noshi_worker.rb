class NoshiWorker
	include Sidekiq::Worker

	def perform(noshi_id, message_id)

		noshi = Noshi.find(noshi_id)
		message = Message.find(message_id)

		# Set up variables
		ntype = noshi.ntype
		omote = noshi.omotegaki
		(omote == '空白') ? (omote = '') : ()
		omote_length = omote.length
		omote_point_size = (168 - (omote_length * 12))

		#make an array with each of the name lines entered
		name_array = Array.new
		name_array << noshi.namae
		name_array << noshi.namae2
		name_array << noshi.namae3
		name_array << noshi.namae4
		name_array << noshi.namae5

		#replace multi-character prefixes with their single charcter versions
		#replace katakana dash with capital I
		#insert line breaks after each letter for Japanese vertical type
		name_array.each do |namae|
			replacements = [ ["(株)", "㈱"], ["(有)", "㈲"], ["ー", "|"] ]
			replacements.each {|replacement| namae.gsub!(replacement[0], replacement[1])}
		end
		def add_line_breaks(string)
			string.scan(/.{1}/).join("\n")
		end
		name_array.map!{ |namae| add_line_breaks(namae)}
		#add line breaks after each character for the omote as well
		omote = add_line_breaks(omote)
		#find the longest string (important: after the character concatenation) in the name array to calculate the point size for the names section
		name_array_max_length = (name_array.map { |namae| namae.length }).max
		name_point_size = (204 - (name_array_max_length * 10))
		#max omote size is 156, and the name needs to be an order smaller than that by default.
		if name_point_size > 108
			name_point_size = 108
		end
		if name_point_size < 65
			name_point_size = 65
		end

		# Pull Noshi Type Image
		noshi_img = MiniMagick::Image.open("#{ENV['GBUCKET_PREFIX']}noshi/noshi#{ntype}.jpg")
		# Create the overlay image
		name_overlay = MiniMagick::Image.open("#{ENV['GBUCKET_PREFIX']}noshi/noshi_blank.png")
		# Normal Noshi and Triple tall noshi.require 'open-uri'
		#font = open(ENV["GBUCKET_PREFIX"] + "fonts/TakaoPMincho.ttf")
		font = "#{Rails.root}/.fonts/TakaoPMincho.ttf"
		if ntype < 15
			# Resize to A4 @ 300dpi
			noshi_img.resize "2480x3508"
			name_overlay.resize "2480x3508"
			#first time for omote
			name_overlay.combine_options do |image|
				image.gravity 'North'
				# Placement based on point size
				omote_placement_y = (348 - (omote_length * (omote_point_size / 2)))
				image.font font
				image.pointsize omote_point_size
				image.fill("#000000")
				image.draw "text 0,#{omote_placement_y} '#{omote}'"
			end
			#count number of names in array, add a name for each time
			name_array.count.times do |i|
				name_overlay.combine_options do |image|
					image.gravity 'North'
					# Placement based on point size and iteration
					name_placement_x = (0 - i * name_point_size)
					(name_array_max_length > 8) ? (name_start_placement_y = 1100) : (name_start_placement_y = 1150)
					(name_array_max_length > 9) ? (name_start_placement_y = 1050) : (name_start_placement_y = 1150)
					name_placement_y = name_start_placement_y + ((i * name_point_size) - (name_point_size / 2))
					image.font font
					image.pointsize name_point_size
					image.fill("#000000")
					image.draw "text #{name_placement_x},#{name_placement_y} '#{name_array[i]}'"
				end
			end
		else
			# Resize to A4 @ 300dpi & *rotate overlay to portrait*
			noshi_img.resize "3508x2480"
			name_overlay.resize "2480x3508"
			name_overlay.rotate "-90"
			name_array.count.times do |i|
				name_overlay.combine_options do |image|
					# Place the Omote if it's ntype 15
					if ntype == 15
						omote_placement_x = 570 - (i * 570 )
						omote_placement_y = 400
						image.font font
						image.pointsize omote_point_size
						image.fill("#000000")
						image.draw "text #{omote_placement_x},#{omote_placement_y} '#{omote}'"
					end
					# Place the names
					image.gravity 'North'
					name_placement_x = 570 - (i * 570 )
					name_placement_y = 1500
					image.font font
					image.pointsize name_point_size + 12
					image.fill("#000000")
					image.draw "text #{name_placement_x},#{name_placement_y} '#{name_array[i]}'"
				end
			end
		end

		noshi_img = noshi_img.composite(name_overlay) do |comp|
			comp.compose "Over"    #OverCompositeOp
			comp.geometry "+0+0"   #copy second_image onto first_image from (0, 0)
		end

		# Setup and save the file
		noshi_img.format "png"
		#name the file
		fname = "#{noshi.omotegaki}_#{noshi.namae}"
		dkey = Time.now.strftime('%Y%m%d%H%M%S')
		ext = '.png'
		final_name = fname + dkey + ext
		#write a temporary version
		noshi_img.write final_name
		#write/stream the file to the uploader
		noshi.image = File.open(final_name)
		noshi.save
		#delete the original temporary
		File.delete(final_name) if File.exist?(final_name)
		noshi_img = nil
		name_overlay = nil
		GC.start

		message.update(state: true, message: "#{noshi.namae}の熨斗作成完了。")

	end

end
