module DownloadTV
  ##
  # EZTV.ag grabber
  class Eztv < LinkGrabber
    def initialize
      super('https://eztv.ag/search/%s')
    end

    def get_links(show)
      # Format the url
      search = format(@url, show)

      data = @agent.get(search).search('a.magnet')

      # Torrent name in data[i].attribute 'title'
      # 'Suits S04E01 HDTV x264-LOL Torrent: Magnet Link'

      # EZTV shows 50 latest releases if it can't find the torrent
      raise NoTorrentsError if data.size == 50

      names = data.collect { |i| i.attribute('title').text.chomp(' Magnet Link') }
      links = data.collect { |i| i.attribute('href').text }

      names.zip(links)
    end
  end
end
