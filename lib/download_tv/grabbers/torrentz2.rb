# frozen_string_literal: true

module DownloadTV
  ##
  # Torrentz2 grabber
  class Torrentz < LinkGrabber
    def initialize
      super('https://torrentz2.nz/search?q=%s')
    end

    def get_links(show)
      raw_data = @agent.get(format(@url, show))
      results = raw_data.search('dl')

      raise NoTorrentsError if results.empty?

      data = results.sort_by { |e| e.search('dd span')[3].text.to_i }.reverse

      data.collect do |i|
        [i.children[0].text.strip,
         i.search('dd span a').first.attribute('href').text]
      end
    end
  end
end
