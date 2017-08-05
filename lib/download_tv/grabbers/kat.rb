module DownloadTV
  ##
  # KATcr.co grabber
  class KAT < LinkGrabber
    def initialize
      super('https://katcr.co/new/search-torrents.php?search="%s"&sort=seeders&order=desc')
    end

    def get_links(s)
      # Format the url
      search = format(@url, s)

      data = @agent.get(search).links.select { |i| i.href.include? 'torrents-details.php?' }

      raise NoTorrentsError if data == []

      # Remove duplicates
      data.keep_if { |i| i.text != '' }

      names = data.collect(&:text)
      links = []

      data.each do |res|
        links << res.click.search('a.kaGiantButton[title="Magnet link"]').attribute('href').text
      end

      names.zip(links)
    end
  end
end
