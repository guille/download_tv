# frozen_string_literal: true

module DownloadTV
  ##
  # Class in charge of managing the link grabbers
  class Torrent
    class << self
      def grabbers
        %w[TorrentAPI Torrentz Eztv]
      end

      def healthcheck
        grabbers.each do |g|
          grabber = (DownloadTV.const_get g).new
          puts "#{g}: #{grabber.online? ? 'online' : 'offline'}"
        end
      end
    end

    def initialize(default_grabber = nil)
      @g_instances = self.class.grabbers\
        .rotate(self.class.grabbers.find_index(default_grabber) || 0)
        .map { |g| (DownloadTV.const_get g).new }
      reset_tries

      remove_grabber_if_offline
    end

    def get_links(show)
      @g_instances.first.get_links(show)
    rescue NoTorrentsError
      if @tries.positive?
        change_grabbers
        retry
      end
      # We're out of grabbers to try
      puts "No torrents found for #{show}"
      []
    ensure
      reset_grabbers_order
    end

    private

    ##
    # This method removes the grabber from the instances list if it is not online
    # It will repeat until it finds an online grabber, or  exit the application
    # if there are none
    def remove_grabber_if_offline
      if @g_instances.empty?
        warn 'There are no available grabbers.'
        exit 1
      end
      return if @g_instances.first.online?

      # We won't be using this grabber
      warn "Problem accessing #{@g_instances.first.class.name}"
      @tries -= 1
      @g_instances.shift # Removes first element
      remove_grabber_if_offline
    end

    def change_grabbers
      @tries -= 1
      @g_instances.rotate!
      remove_grabber_if_offline
    end

    def reset_tries
      @tries = @g_instances.size - 1
    end

    def reset_grabbers_order
      @g_instances.rotate!(@tries + 1)
      reset_tries
    end
  end
end
