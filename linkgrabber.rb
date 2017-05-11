module ShowDownloader

	class LinkGrabber
		attr_reader :url

		def initialize(url)
			@url = url
			
		end
		
		
	end

	class NoTorrentsError < StandardError

	end

	class NoSubtitlesError < StandardError

	end

end