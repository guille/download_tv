module ShowDownloader

	class LinkGrabber
		attr_reader :url

		def initialize(url)
			@url = url
			@agent = Mechanize.new
			
		end

		def test_connection
			agent = Mechanize.new
			agent.read_timeout = 2
			agent.get(@url)
		end
		
	end

	class NoTorrentsError < StandardError

	end

	class NoSubtitlesError < StandardError

	end

end