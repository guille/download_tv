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

			links.each_with_index do |data, i|
				puts "#{i}\t\t#{data[0]}"
				
			end

			puts

			if !auto
				print "Select the torrent you want to download: "

				i = $stdin.gets.chomp.to_i

				while i >= links.size || i < -1
					puts "Index out of bounds. Try again: "
					gets.chomp
				end

				# Use -1 to skip the download
				i == -1 ? "" : links[i][1]
			
			else # Automatically get the links
				links.each do | name, link|
					# find first name without 720p or 1080p
					# result = obj["torrent_results"].find { |i| !i["filename"].include?("720") and !i["filename"].include?("1080") }

				end


			end


		rescue NoTorrentsError
			puts "No torrents found for #{show}"
			LinkGrabber.pending << show

			# Use next grabber
		end
	end

end