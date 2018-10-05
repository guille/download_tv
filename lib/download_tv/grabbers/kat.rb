module DownloadTV
  ##
  # KATcr.co grabber
  class KAT < LinkGrabber
    def initialize
      super('https://katcr.co/advanced-usearch/')
    end

    def get_links(s)
      tries = 0
      max_tries = 5

      params = {
        'category': 'TV',
        'orderby': 'seeds-desc',
        'search': s
      }

      data = @agent.post(@url, params).search('tbody tr td[1]')

      names = data.map { |i| i.search('a.torrents_table__torrent_title b').text }
      links = data.map { |i| i.search('div.torrents_table__actions a[3]').first.attribute('href').text }

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
