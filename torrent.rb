module ShowDownloader

	class Torrent
		attr_accessor :token
		attr_reader :wait
		attr_reader :search_url

		def initialize
			@token = get_token
			@wait = 2.1
			@search_url = "https://torrentapi.org/pubapi_v2.php?mode=search&search_string=%s&token=%s"
		end

		def get_token
			agent = Mechanize.new
			page = agent.get("https://torrentapi.org/pubapi_v2.php?get_token=get_token").content

			obj = JSON.parse(page)

			@token = obj['token']
		end

		def get_link (show)

			s = show.gsub(" ", "+")

			search = @search_url % [s, @token]

			agent = Mechanize.new
			page = agent.get(search).content

			obj = JSON.parse(page)

			if obj["error_code"]==4 # Token expired
				get_token
				search = @search_url % [s, @token]
				page = agent.get(search).content
			 	obj = JSON.parse(page)
			end

			while obj["error_code"]==5 # Violate 1req/2s limit
				sleep(@wait) 
			 	page = agent.get(search).content
			 	obj = JSON.parse(page)
			end

			result = obj["torrent_results"].find { |i| !i["filename"].include?("720") and !i["filename"].include?("1080") }

			result["download"]
		end

	end
end

# Tokens automaticly expire in 15 minutes.
# The api has a 1req/2s limit.
# http://torrentapi.org/apidocs_v2.txt