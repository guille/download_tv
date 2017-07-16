module DownloadTV

	class Torrent

		attr_reader :g_names, :g_instances, :n_grabbers

		def initialize
			@g_names = ["Eztv", "ThePirateBay", "TorrentAPI", "KAT"]
			@g_instances = Array.new
			@n_grabbers = @g_names.size # Initial size
			@tries = @n_grabbers - 1

			@filters = [
				->(n){n.include?("2160")},
				->(n){n.include?("1080")},
				->(n){n.include?("720")},
				->(n){n.include?("WEB")},
				->(n){!n.include?("PROPER") || !n.include?("REPACK")},
			]

			change_grabbers
			
		end

		
		def change_grabbers
			if !@g_names.empty?
				# Instantiates the last element from g_names, popping it
				newt = (DownloadTV.const_get @g_names.pop).new
				newt.test_connection

				@g_instances.unshift newt

			else
				# Rotates the instantiated grabbers
				@g_instances.rotate!

			end

		rescue Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error

			puts "Problem accessing #{newt.class.name}"
			# We won't be using this grabber
			@n_grabbers = @n_grabbers-1
			@tries = @tries - 1

			change_grabbers

		rescue SocketError, Errno::ECONNRESET, Net::OpenTimeout
			puts "Connection error."
			exit
			
		end


		def get_link(show, auto)
			links = @g_instances.first.get_links(show)

			if !auto
				links.each_with_index do |data, i|
					puts "#{i}\t\t#{data[0]}"
					
				end

				puts
				print "Select the torrent you want to download [-1 to skip]: "

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

				links = filter_shows(links)

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
				# TODO: Handle show not found here!!
				return ""
			
			end
			
		end

		def filter_shows(links)
			@filters.each do |f| # Apply each filter
				new_links = links.reject {|name, link| f.(name)}
				# Stop if the filter removes every release
				break if new_links.size == 0

				links = new_links
			end
			links
		end
	end

end