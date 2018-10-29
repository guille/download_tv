# frozen_string_literal: true

module DownloadTV
  ##
  # ThePirateBay grabber
  class ThePirateBay < LinkGrabber
    def initialize(tpb_proxy = 'https://pirateproxy.sh/')
      proxy = tpb_proxy.gsub(%r{/+$}, '')

      super("#{proxy}/search/%s/0/7/0")
    end

    def get_links(show)
      search = format(@url, show)

      # Skip the header
      data = @agent.get(search).search('#searchResult tr').drop 1

      raise NoTorrentsError if data.empty?

      # Second cell of each row contains links and name
      results = data.map { |d| d.search('td')[1] }

      names = results.collect { |i| i.search('.detName').text.strip }
      links = results.collect { |i| i.search('a')[1].attribute('href').text }

      names.zip(links)
    end
  end
end
