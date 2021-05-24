# frozen_string_literal: true

module DownloadTV
  ##
  # EZTV.ag grabber
  class Eztv < LinkGrabber
    def initialize
      super('https://eztv.ag/search/%s')
    end

    def get_links(show)
      raw_data = @agent.get(format(@url, show))
      raw_seeders = raw_data.search('td.forum_thread_post_end').map { |e| e.children[0].text.to_i }
      raw_links = raw_data.search('a.magnet').sort_by.with_index { |_, index| raw_seeders[index] }.reverse

      # Torrent name in raw_links[i].attribute 'title'
      # 'Suits S04E01 HDTV x264-LOL Torrent: Magnet Link'

      # EZTV shows 50 latest releases if it can't find the torrent
      raise NoTorrentsError if raw_links.size == 50

      raw_links.collect do |i|
        [i.attribute('title').text.chomp(' Magnet Link'),
         i.attribute('href').text]
      end
    end
  end
end
