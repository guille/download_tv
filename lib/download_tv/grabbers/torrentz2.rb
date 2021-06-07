# frozen_string_literal: true

module DownloadTV
  ##
  # EZTV.ag grabber
  class Torrentz < LinkGrabber
    def initialize
      super('https://torrentzeu.org/kick.php?q=%s')
    end

    def get_links(show)
      raw_data = @agent.get(format(@url, show))
      results = raw_data.search('tbody tr')

      # require 'byebug'; byebug

      raise NoTorrentsError if results.empty?

      data = results.sort_by { |e| e.search('td[data-title="Last Updated"]')[1].text.to_i }.reverse

      data.collect do |i|
        [i.children[1].text.strip,
         i.children[11].children[1].attribute('href').text]
      end
    end
  end
end
