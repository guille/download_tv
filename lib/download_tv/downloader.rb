# frozen_string_literal: true

module DownloadTV
  ##
  # Entry point of the application
  class Downloader
    attr_reader :config

    def initialize(config = {})
      @config = Configuration.new(config) # Load configuration

      Thread.abort_on_exception = true
    end

    ##
    # Tries to download episodes in order for a given season,
    # until it can't find any
    def download_entire_season(show, season)
      t = Torrent.new(@config.content[:grabber])
      season.insert(0, '0') if season.size == 1
      episode = "#{show} s#{season}e01"
      loop do
        link = get_link(t, episode)
        break if link.empty?

        download(link)
        episode = episode.next
      end
    end

    def download_single_show(show, season = nil)
      t = Torrent.new(@config.content[:grabber])
      show = fix_names([show]).first
      if season
        download_entire_season(show, season)
      else
        download(get_link(t, show))
      end
    end

    ##
    # Given a file containing a list of episodes (one per line)
    # it tries to find download links for each
    def download_from_file(filename)
      if File.exist? filename
        filename = File.realpath(filename)
        t = Torrent.new(@config.content[:grabber])
        to_download = File.readlines(filename, chomp: true)
        fix_names(to_download).each { |show| download(get_link(t, show)) }
      else
        puts "Error: #{filename} not found"
        exit 1
      end
    end

    ##
    # Returns the date from which to check shows
    def date_to_check_from(offset)
      return @config.content[:date] if offset.zero?

      Date.today - offset
    end

    ##
    # Finds download links for all new episodes aired since
    # the last run of the program
    # It connects to MyEpisodes in order to find which shows
    # to track and which new episodes aired.
    # The param +dry_run+ prevents changing the persisted configuration
    # The param +offset+ can be used to move the date back that many days in the check
    # The param +include_tomorrow+ will add the current day to the list of dates to search
    def run(dry_run = false, offset = 0, include_tomorrow: false)
      pending = @config.content[:pending].clone
      @config.content[:pending].clear
      pending ||= []
      date = date_to_check_from(offset)

      pending.concat shows_to_download(date) if date < Date.today
      pending.concat today_shows_to_download if include_tomorrow && date < Date.today.next

      if pending.empty?
        puts 'Nothing to download'
      else
        find_and_download(pending.uniq)
        puts 'Completed. Exiting...'
      end

      unless dry_run
        @config.content[:date] = if include_tomorrow
                                   Date.today.next
                                 else
                                   [Date.today, @config.content[:date]].max
                                 end
        @config.serialize
      end
    rescue InvalidLoginError
      warn 'Wrong username/password combination'
    end

    def find_links(torrent, shows, queue)
      Thread.new do
        shows.each { |show| queue << get_link(torrent, show, save_pending: true) }
        queue.close
      end
    end

    def download_from_queue(queue)
      Thread.new do
        until queue.closed?
          magnet = queue.pop
          download(magnet) if magnet # Doesn't download if no torrents are found
        end
      end
    end

    def find_and_download(shows)
      t = Torrent.new
      queue = Queue.new

      link_t = find_links(t, shows, queue)

      # Downloads the links as they are added
      download_t = download_from_queue(queue)

      link_t.join
      download_t.join
    end

    def shows_to_download(date)
      myepisodes = MyEpisodes.new(@config.content[:myepisodes_user],
                                  @config.content[:cookie])
      myepisodes.load_cookie
      shows = myepisodes.get_shows_since(date)
      shows = reject_ignored(shows)
      fix_names(shows)
    end

    def today_shows_to_download
      myepisodes = MyEpisodes.new(@config.content[:myepisodes_user],
                                  @config.content[:cookie])
      myepisodes.load_cookie
      shows = myepisodes.today_shows
      shows = reject_ignored(shows)
      fix_names(shows)
    end

    ##
    # Uses a Torrent object to obtain links to the given tv show
    # When :auto is true it will try to find the best match
    # based on a set of filters.
    # When it's false it will prompt the user to select the preferred result
    # Returns either a magnet link or nil
    def get_link(torrent, show, save_pending: false)
      links = torrent.get_links(show)

      if links.empty?
        @config.content[:pending] << show if save_pending
        return
      end

      if @config.content[:auto]
        filter_shows(links).first[1]
      else
        prompt_links(links)
        get_link_from_user(links)
      end
    end

    def get_link_from_user(links)
      i = $stdin.gets.chomp.to_i

      until i.between?(-1, links.size - 1)
        puts 'Index out of bounds. Try again [-1 to skip]: '
        i = $stdin.gets.chomp.to_i
      end

      i == -1 ? nil : links[i][1]
    end

    def prompt_links(links)
      links.each_with_index { |data, i| puts "#{i}\t\t#{data[0]}" }

      puts
      print 'Select the torrent you want to download [-1 to skip]: '
    end

    ##
    # Given a list of shows and episodes:
    #
    # * Removes ignored shows
    def reject_ignored(shows)
      shows.reject do |i|
        # Remove season+episode
        @config.content[:ignored]
               .include?(i.split(' ')[0..-2].join(' ').downcase)
      end
    end

    ##
    # Given a list of shows and episodes:
    #
    # * Removes apostrophes, colons and parens
    def fix_names(shows)
      shows.map { |i| i.gsub(/ \(.+\)|[':]/, '') }
    end

    ##
    # Removes links whose names don't match the user filters
    # Runs until no filters are left to be applied or applying
    # a filter would leave no results
    def filter_shows(links)
      @filterer ||= Filterer.new(@config.content[:filters])
      @filterer.filter(links)
    end

    ##
    # Spawns a silent process to download a given magnet link
    def download(link)
      @cmd ||= detect_os

      exec = "#{@cmd} \"#{link}\""

      Process.detach(Process.spawn(exec, %i[out err] => '/dev/null'))
    end

    def detect_os
      case RbConfig::CONFIG['host_os']
      when /linux/
        'xdg-open'
      when /darwin/
        'open'
      else
        warn "You're using an unsupported platform (#{RbConfig::CONFIG['host_os']})."
        exit 1
      end
    end
  end
end
