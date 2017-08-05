module DownloadTV
  ##
  # Class in charge of managing the link grabbers
  class Torrent
    attr_reader :g_names, :g_instances, :n_grabbers

    def grabbers
      %w[Eztv KAT ThePirateBay TorrentAPI]
    end

    def initialize(default_grabber = nil)
      @g_names = grabbers
      @g_instances = []
      @n_grabbers = @g_names.size # Initial size
      @tries = @n_grabbers - 1

      # Silently ignores bad names
      @g_names.rotate! @g_names.find_index(default_grabber).to_i + 1

      change_grabbers
    end

    def change_grabbers
      if !@g_names.empty?
        # Instantiates the last element from g_names, popping it
        newt = (DownloadTV.const_get @g_names.pop).new
        newt.test_connection

        @g_instances.unshift newt

      else
        # Rotates the instantiated grabbers
        @g_instances.rotate!
      end
    rescue Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error
      warn "Problem accessing #{newt.class.name}"
      # We won't be using this grabber
      @n_grabbers -= 1
      @tries = @n_grabbers - 1

      change_grabbers
    rescue SocketError, Errno::ECONNRESET, Net::OpenTimeout
      warn 'Connection error.'
      exit 1
    end

    def get_links(show)
      links = @g_instances.first.get_links(show)

      # Reset the counter
      @tries = @n_grabbers - 1

      links
    rescue NoTorrentsError
      puts "No torrents found for #{show} using #{@g_instances.first.class.name}"

      # Use next grabber
      if @tries > 0
        @tries -= 1
        change_grabbers
        retry

      else # Reset the counter
        @tries = @n_grabbers - 1
        # Handle show not found here!!
        return []
      end
    end
  end
end
