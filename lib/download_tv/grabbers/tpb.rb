# frozen_string_literal: true

module DownloadTV
  ##
  # ThePirateBay grabber
  class ThePirateBay < LinkGrabber
    TRACKERS = %w[
      udp://tracker.coppersurfer.tk:6969/announce
      udp://tracker.openbittorrent.com:6969/announce
      udp://tracker.opentrackr.org:1337
      udp://movies.zsw.ca:6969/announce
      udp://tracker.dler.org:6969/announce
      udp://opentracker.i2p.rocks:6969/announce
      udp://open.stealth.si:80/announce
      udp://tracker.0x.tf:6969/announce
    ]

    def initialize
      super("https://tpb36.ukpass.co/apibay/q.php?q=%s&cat=")
    end

    def get_links(show)
      search = format(@url, show)

      data = agent.get(search)
      parsed = JSON.parse(data.body)

      raise NoTorrentsError if parsed.size == 1 && parsed.first['name'] == 'No results returned'

      parsed.map do |elem|
        [elem['name'], build_magnet(elem['info_hash'], elem['name'])]
      end
    end

    private

    def build_magnet(torrent_hash, name)
      "magnet:?xt=urn:btih:#{torrent_hash}&dn=#{CGI.escape(name)}#{trackers_params}"
    end

    def trackers_params
      trackers_params ||= "&tr=#{TRACKERS.map { |tracker| CGI.escape(tracker) }.join('&tr=')}"
    end
  end
end
