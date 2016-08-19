module ShowDownloader

	class LinkGrabber
		attr_reader :url, :sep

		def initialize(url, sep)
			@url = url
			@sep = sep
			@@pending = Array.new
			
		end

		# Access as LinkGrabber.pending
		def self.pending
			@@pending
			
		end
		
		
	end

	class NoTorrentsError < StandardError

	end

end