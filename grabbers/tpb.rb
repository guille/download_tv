module ShowDownloader
	class ThePirateBay < LinkGrabber
		def initialize
			super("https://thepiratebay.rs/search/%s/0/7/0")
		end

		def get_links(s)

			# Format the url
			search = @url % [s]

			agent = Mechanize.new
			data = agent.get(search).search("#searchResult tr")
			# Skip the header
			data = data.drop 1

			# Second cell of each row contains links and name
			results = data.map { |d| d.search("td")[1] }

			names = results.collect {|i| i.search(".detName").text.strip }
			links = results.collect {|i| i.search("a")[1].attribute("href") }

			names.zip(links)

		end

	end
end