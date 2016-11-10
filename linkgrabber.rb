module ShowDownloader

	class LinkGrabber
		attr_reader :url, :sep

		def initialize(url, sep)
			@url = url
			@sep = sep
			
		end
		
		
	end

	class NoTorrentsError < StandardError

	end

	class NoSubtitlesError < StandardError

	end

end