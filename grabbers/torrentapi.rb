module ShowDownloader

	class TorrentAPI < LinkGrabber

		attr_accessor :token
		attr_reader :wait

		def initialize
			super("https://torrentapi.org/pubapi_v2.php?mode=search&search_string=%s&token=%s", "+")
			@token = get_token
			@wait = 2.1
			
		end

		##
		# Connects to Torrentapi.org and requests a token.
		# Returns said token.
		def get_token
			agent = Mechanize.new
			page = agent.get("https://torrentapi.org/pubapi_v2.php?get_token=get_token").content
			obj = JSON.parse(page)

			@token = obj['token']

		end

		def get_links(show)

			# Change spaces for the separator
			s = show.gsub(" ", @sep)

			# Format the url
			search = @url % [s, @token]

			agent = Mechanize.new
			page = agent.get(search).content
			obj = JSON.parse(page)

			if obj["error_code"]==4 # Token expired
				get_token
				search = @url % [s, @token]
				page = agent.get(search).content
				obj = JSON.parse(page)
			end

			while obj["error_code"]==5 # Violate 1req/2s limit
				sleep(@wait) 
				page = agent.get(search).content
				obj = JSON.parse(page)

			end

			raise NoTorrentsError if obj["error"]

			names = obj["torrent_results"].collect {|i| i["filename"]}
			links = obj["torrent_results"].collect {|i| i["download"]}

			names.zip(links)

		end

	end

end

# Tokens automaticly expire in 15 minutes.
# The api has a 1req/2s limit.
# http://torrentapi.org/apidocs_v2.txt