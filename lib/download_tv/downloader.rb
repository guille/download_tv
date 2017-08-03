module DownloadTV

	class Downloader

		attr_reader :offset, :config

		def initialize(offset=0, config={})
			@offset = offset.abs
			@config = Configuration.new(config).content # Load configuration
			
			@filters = [
				->(n){ n.include?("2160p") },
				->(n){ n.include?("1080p") },
				->(n){ n.include?("720p")  },
				->(n){ n.include?("WEB")   },
				->(n){ !n.include?("PROPER") && !n.include?("REPACK") },
			]
			
			Thread.abort_on_exception = true
		end

		def download_single_show(show)
			t = Torrent.new(@config[:grabber])
			download(get_link(t, show))
		end


		##
		# Given a file containing a list of episodes (one per line), it tries to find download links for each
		def download_from_file(filename)
			if !File.exist? filename
				puts "Error: #{filename} not found" 
				exit 1
			end
			filename = File.realpath(filename)
			t = Torrent.new(@config[:grabber])
			File.readlines(filename).each { |show| download(get_link(t, show)) }
		end

		##
		# Finds download links for all new episodes aired since the last run of the program
		# It connects to MyEpisodes in order to find which shows to track and which new episodes aired.
		def run(dont_update_last_run)
			date = check_date

			myepisodes = MyEpisodes.new(@config[:myepisodes_user], @config[:cookie])
			# Log in using cookie by default
			myepisodes.load_cookie
			shows = myepisodes.get_shows(date)
			
			if shows.empty?
				puts "Nothing to download"

			else
				t = Torrent.new(@config[:grabber])
				to_download = fix_names(shows)

				queue = Queue.new
				
				# Adds a link (or empty string to the queue)
				link_t = Thread.new do
					to_download.each { |show| queue << get_link(t, show) }
				end

				# Downloads the links as they are added
				download_t = Thread.new do
					to_download.size.times do
						magnet = queue.pop
						next if magnet == "" # Doesn't download if no torrents are found
						download(magnet)
					end
				end

				# Downloading the subtitles
				# subs_t = @config[:subs] and Thread.new do
				# 	to_download.each { |show| @s.get_subs(show) }
				# end

				link_t.join
				download_t.join
				# subs_t.join

				puts "Completed. Exiting..."
			end

			@config[:date] = Date.today unless dont_update_last_run

		rescue InvalidLoginError
			warn "Wrong username/password combination"
		end

		##
		# Uses a Torrent object to obtain links to the given tv show
		# When :auto is true it will try to find the best match based on a set of filters
		# When it's false it will prompt the user to select the preferred result
		# Returns either a magnet link or an emptry string
		def get_link(t, show)
			links = t.get_links(show)

			return "" if links.empty?

			if @config[:auto]
				links = filter_shows(links)
				links.first[1]
			
			else
				puts "Collecting links for #{show}"
				links.each_with_index { |data, i| puts "#{i}\t\t#{data[0]}" }
				
				puts
				print "Select the torrent you want to download [-1 to skip]: "

				i = $stdin.gets.chomp.to_i

				while i >= links.size || i < -1
					puts "Index out of bounds. Try again [-1 to skip]: "
					i = $stdin.gets.chomp.to_i
				end

				# Use -1 to skip the download
				i == -1 ? "" : links[i][1]
			end
			
		end


		def check_date
			last = @config[:date]
			if last - @offset != Date.today
				last - @offset
			else
				puts "Everything up to date"
				exit
			end
		end


		##
		# Given a list of shows and episodes:
		#
		# * Removes ignored shows
		# * Removes apostrophes, colons and parens
		def fix_names(shows)
			# Ignored shows
			s = shows.reject do |i|
				# Remove season+episode
				@config[:ignored].include?(i.split(" ")[0..-2].join(" ").downcase)
			end

			s.map { |i| i.gsub(/ \(.+\)|[':]/, "") }
		end

		##
		# Iteratively applies filters until they've all been applied or applying the next filter would result in no results
		# These filters are defined at @filters
		def filter_shows(links)
			@filters.each do |f| # Apply each filter
				new_links = links.reject { |name, _link| f.(name) }
				# Stop if the filter removes every release
				break if new_links.size == 0

				links = new_links
			end

			links
		end


		##
		# Spawns a silent process to download a given magnet link
		# Uses xdg-open (not portable)
		def download(link)
			@cmd ||= detect_os
			
			exec = "#{@cmd} \"#{link}\""
			
			Process.detach(Process.spawn(exec, [:out, :err]=>"/dev/null"))

		end

		def detect_os
			case RbConfig::CONFIG['host_os']
			when /linux/
				"xdg-open"
			when /darwin/
				"open"
			else
				warn "You're using an unsupported platform."
				exit 1
			end
		end
	end
end
