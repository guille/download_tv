module ShowDownloader

	class Torrent
		def initialize
			# Loads every file in /grabbers
			@grabbers = Array.new

			manage_grabbers
			
		end

		def manage_grabbers
			# add grabbers to the array

			# @a = Eztv.new
			@a = TorrentAPI.new

			
		rescue Mechanize::ResponseCodeError
			puts "Problem accessing torrentapi.org"
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
					# Not neeeded:
					# break if links.size == 1
				end

				# Get the first result left
				links[0][1]
				

			end

		rescue NoTorrentsError
			puts "No torrents found for #{show}"
			LinkGrabber.pending << show
			return ""

			# Use next grabber
		end
	end

end