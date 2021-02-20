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

    def download_single_show(show, season = nil)
      t = Torrent.new(@config.content[:grabber])
      show = fix_names([show]).first
      if season
        season.insert(0, '0') if season.size == 1
        episode = "#{show} s#{season}e01"
        loop do
          link = get_link(t, episode)
          break if link.empty?

          download(link)
          episode = episode.next
        end
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
    # Finds download links for all new episodes aired since
    # the last run of the program
    # It connects to MyEpisodes in order to find which shows
    # to track and which new episodes aired.
    # The param +dont_update_last_run+ prevents changing the configuration's date value
    # The param +offset+ can be used to move the date back that many days in the check
    # The param +include_tomorrow+ will add the current day to the list of dates to search
    def run(dont_update_last_run, offset = 0, include_tomorrow = false)
      pending = @config.content[:pending].clone
      @config.content[:pending].clear
      pending ||= []
      date = check_date(offset)

      pending.concat shows_to_download(date) if date

      if pending.empty?
        puts 'Nothing to download'
      else
        find_and_download(pending.uniq)
        puts 'Completed. Exiting...'
      end

      @config.content[:date] = [Date.today, @config.content[:date]].max unless dont_update_last_run
      @config.serialize
    rescue InvalidLoginError
      warn 'Wrong username/password combination'
    end

    ##
    # Finds download links for all the episodes set to air today.
    # TODO: Refactor with #run()
    def run_ahead(dont_update_last_run)
      pending = @config.content[:pending].clone
      @config.content[:pending].clear
      pending ||= []

      # Make normal run first if necessary
      if @config.content[:date] < Date.today
        pending.concat shows_to_download(@config.content[:date])
      end

      # Only do --tomorrow run if it hasn't happened already
      if @config.content[:date] < Date.today.next
        pending.concat today_shows_to_download
      end

      if pending.empty?
        puts 'Nothing to download'
      else
        find_and_download(pending.uniq)
        puts 'Completed. Exiting...'
      end

      @config.content[:date] = Date.today.next unless dont_update_last_run
      @config.serialize
    rescue InvalidLoginError
      warn 'Wrong username/password combination'
    end

    def find_and_download(shows)
      t = Torrent.new
      queue = Queue.new

      # Adds a link (or empty string to the queue)
      link_t = Thread.new do
        shows.each { |show| queue << get_link(t, show, true) }
      end

      # Downloads the links as they are added
      download_t = Thread.new do
        shows.size.times do
          magnet = queue.pop
          next if magnet == '' # Doesn't download if no torrents are found

          download(magnet)
        end
      end

      # Downloading the subtitles
      # subs_t = @config.content[:subs] and Thread.new do
      #   shows.each { |show| @s.get_subs(show) }
      # end

      link_t.join
      download_t.join
      # subs_t.join
    end

    def shows_to_download(date)
      myepisodes = MyEpisodes.new(@config.content[:myepisodes_user],
                                  @config.content[:cookie])
      # Log in using cookie by default
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
    # Returns either a magnet link or an emptry string
    def get_link(torrent, show, save_pending = false)
      links = torrent.get_links(show)

      if links.empty?
        @config.content[:pending] << show if save_pending
        return ''
      end

      if @config.content[:auto]
        links = filter_shows(links)
        links.first[1]
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

      i == -1 ? '' : links[i][1]
    end

    def prompt_links(links)
      links.each_with_index { |data, i| puts "#{i}\t\t#{data[0]}" }

      puts
      print 'Select the torrent you want to download [-1 to skip]: '
    end

    ##
    # Returns the date from which to check shows
    # or nil if the program was already ran today
    # Passing an offset skips this check
    def check_date(offset)
      if offset.zero?
        last = @config.content[:date]
        last if last < Date.today
      else
        Date.today - offset
      end
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
      f = Filterer.new(@config.content[:filters])
      f.filter(links)
    end

    ##
    # Spawns a silent process to download a given magnet link
    # Uses xdg-open (not portable)
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
        warn "You're using an unsupported platform."
        exit 1
      end
    end
  end
end
