# frozen_string_literal: true

module DownloadTV
  ##
  # Class in charge of managing the link grabbers
  class Torrent
    attr_reader :g_instances, :tries

    def grabbers
      # %w[TorrentAPI ThePirateBay Eztv KAT]
      %w[TorrentAPI ThePirateBay Eztv]
    end

    def initialize(default_grabber = nil)
      g_names = grabbers

      # Silently ignores bad names
      found_default = g_names.find_index(default_grabber)
      g_names.rotate! found_default if found_default

      @g_instances = g_names.map { |g| (DownloadTV.const_get g).new }
      reset_tries

      check_grabber_online
    end

    def check_grabber_online
      if @g_instances.empty?
        warn 'There are no available grabbers.'
        exit 1
      end
      return if @g_instances.first.online?

      # We won't be using this grabber
      warn "Problem accessing #{@g_instances.first.class.name}"
      @tries -= 1
      @g_instances.shift # Removes first element
      check_grabber_online
    end

    def change_grabbers
      # Rotates the instantiated grabbers
      @g_instances.rotate!
      check_grabber_online
    end

    def get_links(show)
      links = @g_instances.first.get_links(show)

      reset_grabbers_order
      reset_tries

      links
    rescue NoTorrentsError
      puts "No torrents found for #{show} "\
           "using #{@g_instances.first.class.name}"

      # Use next grabber
      if @tries.positive?
        @tries -= 1
        change_grabbers
        retry

      else
        reset_grabbers_order
        reset_tries
        # Handle show not found here!!
        return []
      end
    end

    def reset_tries
      @tries = @g_instances.size - 1
    end

    def reset_grabbers_order
      @g_instances.rotate!(@tries + 1)
    end
  end
end
