module DownloadTV

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

		def get_links(s)
			raise NotImplementedError
		end
		
	end

	class NoTorrentsError < StandardError

	end

	class NoSubtitlesError < StandardError

	end

end