require 'json'
require 'mechanize'
require 'date'
require 'io/console'
require_relative 'torrent'
require_relative 'myepisodes'

module ShowDownloader

	class Downloader

		attr_reader :app, :offset

		def initialize(args)
			@app = args[0]
			@offset = args[1].to_i || 0
		end

		def run
			Dir.chdir(File.dirname(__FILE__))
			
			check = check_date

			exit if check[0]

			print "Enter your MyEpisodes password: "
			pass = STDIN.noecho(&:gets).chomp
			puts

			shows = MyEpisodes.get_shows "Cracky7", pass, check[1]

			t = Torrent.new

			fix_names(shows).each do |show|
				download(t.get_link(show))
			end

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
			# Removes dots and parens
			s = shows.map do |term|
				term.gsub(/(\.|\(|\))/, "")
			end

			# Ignored shows
			ignored = File.read("ignored").split("\n")
			s.reject do |i|
				ignored.include?(i.split(" ")[0..-2].join(" "))
			end
		end

		def download(link)
			exec = "#{@app} \"#{link}\""
			
			Process.detach(Process.spawn(exec, [:out, :err]=>"/dev/null"))
		end

	end
end