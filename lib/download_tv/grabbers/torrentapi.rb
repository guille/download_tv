# frozen_string_literal: true

module DownloadTV
  ##
  # TorrentAPI.org grabber
  # Interfaces with http://torrentapi.org/apidocs_v2.txt
  class TorrentAPI < LinkGrabber
    TOKEN_EXPIRED_ERROR = 4
    TOO_MANY_REQUESTS_ERROR = 5 # 1req/2s

    def initialize
      super('https://torrentapi.org/pubapi_v2.php?'\
            'mode=search&search_string=%s&token=%s&'\
            'app_id=DownloadTV&sort=seeders')
      @wait = 0.5
      @token = nil
    end

    ##
    # Specific implementation for TorrentAPI (requires token)
    def online?
      renew_token
      true
    rescue Mechanize::ResponseCodeError => e
      if e.response_code == '429'
        sleep(@wait)
        retry
      end
      false
    rescue Net::HTTP::Persistent::Error
      false
    end

    ##
    # Makes a get request tp the given url.
    # Returns the JSON response parsed into a hash
    def request_and_parse(url)
      page = agent.get(url).content
      JSON.parse(page)
    end

    ##
    # Connects to Torrentapi.org and requests a token, returning it
    # Tokens automatically expire every 15 minutes
    def renew_token
      obj = request_and_parse('https://torrentapi.org/pubapi_v2'\
                              '.php?get_token=get_token&app_id='\
                              'DownloadTV')

      @token = obj['token']
    end

    def get_links(show)
      renew_token if @token.nil?

      search = format(@url, show, @token)

      obj = request_and_parse(search)

      if obj['error_code'] == TOKEN_EXPIRED_ERROR
        renew_token
        search = format(@url, show, @token)
        obj = request_and_parse(search)
      end

      while obj['error_code'] == TOO_MANY_REQUESTS_ERROR || obj.has_key?('rate_limit')
        sleep(@wait)
        obj = request_and_parse(search)
      end

      raise NoTorrentsError if obj['error']

      names = obj['torrent_results'].collect { |i| i['filename'] }
      links = obj['torrent_results'].collect { |i| i['download'] }

      names.zip(links)
    rescue Mechanize::ResponseCodeError => e
      if e.response_code == '429'
        sleep(@wait)
        retry
      end
    end
  end
end
