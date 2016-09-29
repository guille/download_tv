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

		attr_reader :offset, :t, :auto, :subs

		def initialize(offset=0)
			@offset = offset.to_i
			@t = Torrent.new
			@auto = ShowDownloader::CONFIG[:auto]
			# @subs = ShowDownloader::CONFIG[:subs]
			Thread.abort_on_exception = true
		end

		def download_single_show(show)
			download(@t.get_link(show, @auto))
		end

		##
		# Gets the links.
		def run
			Dir.chdir(File.dirname(__FILE__))
			
			check, date = check_date

			exit if check

			print "Enter your MyEpisodes password: "
			pass = STDIN.noecho(&:gets).chomp
			puts

			shows = MyEpisodes.get_shows(ShowDownloader::CONFIG[:myepisodes_user], pass, date)
			
			puts "Nothing to download" if shows.empty?

			to_download = fix_names(shows)

			queue = Queue.new
			
			link_t = Thread.new do
				# Adds a link (or empty string to the queue)
				to_download.each { |show| queue << @t.get_link(show, @auto) }
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
			# subs_t = @subs && Thread.new do
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
			content = File.read("date")
			
			last = Date.parse(content)
			if last - @offset != Date.today
				[false, last - @offset]
			else
				puts "Everything up to date"
				[true, nil]
			end
			
		rescue Errno::ENOENT
			File.write("date", Date.today-1)
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
