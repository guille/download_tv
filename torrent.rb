module ShowDownloader

	class Torrent

		attr_reader :g_names, :g_instances, :n_grabbers

		def initialize
			@g_names = ["Eztv", "TorrentAPI"]
			@g_instances = Array.new
			@n_grabbers = @g_names.size # Initial size
			@tries = @n_grabbers - 1

			@filters = Array.new
			@filters << ->(n){n.include?("2160")}
			@filters << ->(n){n.include?("1080")}
			@filters << ->(n){n.include?("720")}
			@filters << ->(n){n.include?("WEB")}
			@filters << ->(n){!n.include?("PROPER") || !n.include?("REPACK")}

			change_grabbers
			
		end

		
		def change_grabbers
			if !@g_names.empty?
				# Instantiates the last element from g_names, popping it
				@g_instances.unshift (Object.const_get "ShowDownloader::#{@g_names.pop}").new

			else
				# Rotates the instantiated grabbers
				@g_instances.rotate!

			end

		rescue Mechanize::ResponseCodeError
			puts "Problem accessing torrentapi.org"
			change_grabbers

		rescue SocketError, Errno::ECONNRESET
			puts "Check your internet connection"
			exit
			
		end


		def get_link(show, auto)
			links = @g_instances.first.get_links(show)

			if !auto
				links.each_with_index do |data, i|
					puts "#{i}\t\t#{data[0]}"
					
				end

				puts
				print "Select the torrent you want to download: "

				i = $stdin.gets.chomp.to_i

				while i >= links.size || i < -1
					puts "Index out of bounds. Try again: "
					i = $stdin.gets.chomp.to_i
				end

				# Reset the counter
				@tries = @n_grabbers - 1

				# Use -1 to skip the download
				i == -1 ? "" : links[i][1]
			
			else # Automatically get the links

				@filters.each do |f| # Apply each filter
					new_links = links.reject {|name, link| f.(name)}
					# Stop if the filter removes every release
					break if new_links.size == 0

					links = new_links
				end

				# Reset the counter
				@tries = @n_grabbers - 1

				# Get the first result left
				links[0][1]
				
			end

		rescue NoTorrentsError
			puts "No torrents found for #{show} using #{@g_instances.first.class.name}"

			# Use next grabber
			if @tries > 0
				@tries-=1
				change_grabbers
				retry

			else # Reset the counter
				@tries = @n_grabbers - 1
				return ""
			
			end
			
		end
	end

end