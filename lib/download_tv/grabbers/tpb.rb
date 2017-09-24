module DownloadTV
  ##
  # ThePirateBay grabber
  class ThePirateBay < LinkGrabber
    def initialize(tpb_proxy = 'https://thepiratebay.cr')
      proxy = tpb_proxy.gsub(%r{/+$}, '') || 'https://thepiratebay.cr'

      super("#{proxy}/search/%s/0/7/0")
    end

    def get_links(s)
      # Format the url
      search = format(@url, s)

      data = @agent.get(search).search('#searchResult tr')
      # Skip the header
      data = data.drop 1

      raise NoTorrentsError if data.empty?

      # Second cell of each row contains links and name
      results = data.map { |d| d.search('td')[1] }

      names = results.collect { |i| i.search('.detName').text.strip }
      links = results.collect { |i| i.search('a')[1].attribute('href').text }

      names.zip(links)
    end
  end
end
