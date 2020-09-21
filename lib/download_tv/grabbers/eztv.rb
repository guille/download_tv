# frozen_string_literal: true

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

      raw_data = @agent.get(search)
      raw_links = raw_data.search('a.magnet')
      raw_seeders = raw_data.search('td.forum_thread_post_end').map { |e| e.children[0].text.to_i }
      raw_links = raw_links.sort_by.with_index {|elem, index| raw_seeders[index]}.reverse

      # Torrent name in raw_links[i].attribute 'title'
      # 'Suits S04E01 HDTV x264-LOL Torrent: Magnet Link'

      # EZTV shows 50 latest releases if it can't find the torrent
      raise NoTorrentsError if raw_links.size == 50

      names = raw_links.collect do |i|
        i.attribute('title')
         .text
         .chomp(' Magnet Link')
      end
      links = raw_links.collect do |i|
        i.attribute('href')
         .text
      end

      names.zip(links)
    end
  end
end
