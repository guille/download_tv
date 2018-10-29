# frozen_string_literal: true

module DownloadTV
  ##
  # KATcr.co grabber
  class KAT < LinkGrabber
    def initialize
      super('https://katcr.co/advanced-usearch/')
    end

    def get_links(show)
      tries = 0
      max_tries = 5

      params = {
        'category': 'TV',
        'orderby': 'seeds-desc',
        'search': show
      }

      data = @agent.post(@url, params)
                   .search('tbody tr td[1]')

      names = data.map do |i|
        i.search('a.torrents_table__torrent_title b')
         .text
      end
      links = data.map do |i|
        i.search('div.torrents_table__actions a[3]')
         .first
         .attribute('href')
         .text
      end

      raise NoTorrentsError if data.empty?

      names.zip(links)
    rescue Net::HTTP::Persistent::Error => e
      raise unless e.message =~ /too many connection resets/
      raise if tries >= max_tries

      tries += 1
      retry
    end
  end
end
