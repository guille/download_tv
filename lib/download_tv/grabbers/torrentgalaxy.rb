# frozen_string_literal: true

module DownloadTV
  ##
  # TorrentGalaxy grabber
  class TorrentGalaxy < LinkGrabber
    def initialize
      super('https://torrentgalaxy.to/torrents.php?search=%s&sort=seeders&order=desc')
    end

    def get_links(show)
      raw_data = agent.get(format(@url, show))
      rows = raw_data.search('div.tgxtablerow')

      raise NoTorrentsError if rows.size.zero?

      rows.map do |row|
        [row.children[4].text.strip,
         row.children[5].children[1].attribute('href').text]
      end
    end
  end
end
