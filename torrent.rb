module ShowDownloader

	class Torrent
		attr_reader :grabbers, :tries

		def initialize
			# Loads every class name in /grabbers
			@grabbers = ["TorrentAPI", "Eztv"]
			@tries = @grabbers.size-1

			change_grabbers
			
		end

		
		def change_grabbers
			# Instantiates the first one
			@a = (Object.const_get "ShowDownloader::#{@grabbers.first}").new
			# Pushes it back
			@grabbers.rotate!

		rescue Mechanize::ResponseCodeError
			puts "Problem accessing torrentapi.org"
			change_grabbers
		end


		def get_link(show, auto)

			links = @a.get_links(show)

			if !auto
				
				links.each_with_index do |data, i|
					puts "#{i}\t\t#{data[0]}"
					
				end

				puts

				print "Select the torrent you want to download: "

				i = $stdin.gets.chomp.to_i

				while i >= links.size || i < -1
					puts "Index out of bounds. Try again: "
					gets.chomp
				end

				# Reset the counter
				@tries = @grabbers.size-1

				# Use -1 to skip the download
				i == -1 ? "" : links[i][1]
			
			else # Automatically get the links
				filters = Array.new
				filters << ->(n){n.include?("1080")}
				filters << ->(n){n.include?("720")}
				filters << ->(n){n.include?("WEB")}
				filters << ->(n){!n.include?("PROPER") || !n.include?("REPACK")}

				filters.each do |f|
					# Apply each filter
					new_links = links.reject {|name, link| f.(name)}
					# Stop if the filter removes every release
					break if new_links.size == 0

					links = new_links
				end

				# Reset the counter
				@tries = @grabbers.size-1

				# Get the first result left
				links[0][1]
				

			end

		rescue NoTorrentsError
			puts "No torrents found for #{show} using #{@a.class.name}"
			LinkGrabber.pending << show

			# Use next grabber
			if @tries > 0
				@tries-=1
				change_grabbers
				retry
				
			end

			# Reset the counter
			@tries = @grabbers.size-1
			return ""

			
		end
	end

end