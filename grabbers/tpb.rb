module ShowDownloader

	class ThePirateBay < LinkGrabber

		def initialize()
			proxy = ShowDownloader::CONFIG[:tpb_proxy].gsub(/\/+$/, "") || "https://thepiratebay.cr"

			super("#{proxy}/search/%s/0/7/0")
			
		end

		def get_links(s)

			# Format the url
			search = @url % [s]

			data = @agent.get(search).search("#searchResult tr")
			# Skip the header
			data = data.drop 1

			raise NoTorrentsError if data.size == 0

			# Second cell of each row contains links and name
			results = data.map { |d| d.search("td")[1] }

			names = results.collect {|i| i.search(".detName").text.strip }
			links = results.collect {|i| i.search("a")[1].attribute("href") }

			names.zip(links)

		end

	end
end