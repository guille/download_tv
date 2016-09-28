require 'json'
require 'mechanize'
require 'date'
require 'io/console'
require_relative 'torrent'
require_relative 'myepisodes'
require_relative 'linkgrabber'
require_relative 'subtitles'
require_relative 'config'
require_relative 'grabbers/torrentapi'
require_relative 'grabbers/addic7ed'
require_relative 'grabbers/eztv'

module ShowDownloader

	class Downloader

		attr_reader :offset
		attr_reader :t

		def initialize(args = [])
			@offset = args[0].to_i || 0
			@t = Torrent.new
			Thread.abort_on_exception = true
		end

		def download_single_show(show)
			download(@t.get_link(show, true))
		end

		##
		# Gets the links.
		# Auto flag means it selects the torrent without user input
		def run(auto = true, subs = true)
			Dir.chdir(File.dirname(__FILE__))
			
			check, date = check_date

			exit if check

			print "Enter your MyEpisodes password: "
			pass = STDIN.noecho(&:gets).chomp
			puts

			shows = MyEpisodes.get_shows(ShowDownloader::CONFIG[myepisodes_user], pass, date)
			
			puts "Nothing to download" if shows.empty?

			to_download = fix_names(shows)

			queue = Queue.new
			
			link_t = Thread.new do
				# Adds a link (or empty string to the queue)
				to_download.each { |show| queue << @t.get_link(show, auto) }
			end

			download_t = Thread.new do
				# Downloads every links as they are added
				to_download.size.times do
					magnet = queue.pop
					next if magnet == "" # Doesnt download if no torrents are found
					download(magnet)
				end
			end

			# Another thread for downloading the subtitles
			# subs_t = subs && Thread.new do
			# 	to_download.each { |show| @s.get_subs(show) }
			# end

			# Only necessary to join one? Maybe neither
			link_t.join
			download_t.join
			# subs_t.join

			puts "Completed. Exiting..."

			File.write("date", Date.today)

		rescue AuthenticationError
			puts "Wrong username/password combination"
		end

		def check_date
			if !File.exist?("date")
				File.write("date", Date.today-1)
			end
			last = Date.parse(File.read("date"))
			if last != Date.today
				[false, last - @offset]
			else
				puts "Everything up to date"
				[true, nil]
			end
			
		end

		def fix_names(shows)
			# Removes apostrophes and parens
			s = shows.map do |term|
				term.gsub(/[()']/, "")
			end

			# Ignored shows
			ignored = File.read("ignored").split("\n")
			s.reject do |i|
				ignored.include?(i.split(" ")[0..-2].join(" "))
			end
		end

		def download(link)
			exec = "xdg-open \"#{link}\""
			
			Process.detach(Process.spawn(exec, [:out, :err]=>"/dev/null"))

		end

	end
end
