module DownloadTV
  ##
  # KATcr.co grabber
  class KAT < LinkGrabber
    def initialize
      super('https://katcr.co/advanced-usearch/')
    end

    def get_links(s)
      params = {
        'category': 'TV',
        'orderby': 'seeds-desc',
        'search': s
      }
      
      data = @agent.post(@url, params).search("table.torrents_table tbody tr td[1]")

      names = data.map { |i| i.search('a.torrents_table__torrent_title b').text }
      links = data.map { |i| i.search('div.torrents_table__actions a[3]').first.attribute('href').text }

      raise NoTorrentsError if data.size == 0

      names.zip(links)
    end
  end
end
