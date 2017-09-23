module DownloadTV
  ##
  # Interface for the grabbers
  class LinkGrabber
    attr_reader :url

    def initialize(url)
      @url = url
      @agent = Mechanize.new
      @agent.user_agent = DownloadTV::USER_AGENT
    end

    def test_connection
      @agent.read_timeout = 2
      @agent.get(@url)
    end

    def get_links(_s)
      raise NotImplementedError
    end
  end

  class NoTorrentsError < StandardError; end

  class NoSubtitlesError < StandardError; end
end
