module DownloadTV
  ##
  # TorrentAPI.org grabber
  class TorrentAPI < LinkGrabber
    attr_accessor :token
    attr_reader :wait

    def initialize
      super('https://torrentapi.org/pubapi_v2.php?mode=search&search_string=%s&token=%s&app_id=DownloadTV')
      @wait = 2.1
    end

    ##
    # Specific implementation for TorrentAPI (requires token)
    def test_connection
      @agent.read_timeout = 2
      @agent.get(format(@url, 'test', 'test'))
    end

    ##
    # Connects to Torrentapi.org and requests a token.
    # Returns said token.
    def renew_token
      page = @agent.get('https://torrentapi.org/pubapi_v2.php?get_token=get_token&app_id=DownloadTV').content

      obj = JSON.parse(page)

      @token = obj['token']
      # Tokens automaticly expire in 15 minutes.
      # The api has a 1req/2s limit.
      # http://torrentapi.org/apidocs_v2.txt
    end

    def get_links(s)
      @token ||= renew_token

      # Format the url
      search = format(@url, s, @token)

      page = @agent.get(search).content
      obj = JSON.parse(page)

      if obj['error_code'] == 4 # Token expired
        renew_token
        search = format(@url, s, @token)
        page = @agent.get(search).content
        obj = JSON.parse(page)
      end

      while obj['error_code'] == 5 # Violate 1req/2s limit
        # puts 'Torrentapi request limit hit. Wait a few seconds...'
        sleep(@wait)
        page = @agent.get(search).content
        obj = JSON.parse(page)

      end

      raise NoTorrentsError if obj['error']

      names = obj['torrent_results'].collect { |i| i['filename'] }
      links = obj['torrent_results'].collect { |i| i['download'] }

      names.zip(links)
    end
  end
end
