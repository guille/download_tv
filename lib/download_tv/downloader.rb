# frozen_string_literal: true

module DownloadTV
  ##
  # Entry point of the application
  class Downloader
    attr_reader :config

    def initialize(config = {})
      @config = Configuration.new(config) # Load configuration

      @filters = [
        ->(n) { n.include?('2160p') },
        ->(n) { n.include?('1080p') },
        ->(n) { n.include?('720p')  },
        # ->(n) { n.include?('WEB')   },
        ->(n) { !n.include?('PROPER') && !n.include?('REPACK') }
      ]

      Thread.abort_on_exception = true
    end

    def download_single_show(show)
      t = Torrent.new(@config.content[:grabber])
      show = fix_names([show]).first
      download(get_link(t, show))
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
    def run(dont_update_last_run, offset = 0)
      pending = @config.content[:pending]
      @config.content[:pending].clear
      pending ||= []
      date = check_date(offset)
      if pending.empty? && date.nil?
        puts 'Everything up to date'
        exit
      end

      to_download = shows_to_download(date)
      to_download.concat pending

      if to_download.empty?
        puts 'Nothing to download'

      else
        t = Torrent.new 

        queue = Queue.new

        # Adds a link (or empty string to the queue)
        link_t = Thread.new do
          to_download.each { |show| queue << get_link(t, show, true) }
        end

        # Downloads the links as they are added
        download_t = Thread.new do
          to_download.size.times do
            magnet = queue.pop
            next if magnet == '' # Doesn't download if no torrents are found

            download(magnet)
          end
        end

        # Downloading the subtitles
        # subs_t = @config.content[:subs] and Thread.new do
        #   to_download.each { |show| @s.get_subs(show) }
        # end

        link_t.join
        download_t.join
        # subs_t.join

        puts 'Completed. Exiting...'
      end

      @config.content[:date] = Date.today unless dont_update_last_run
      @config.serialize
    rescue InvalidLoginError
      warn 'Wrong username/password combination'
    end

    def shows_to_download(date)
      myepisodes = MyEpisodes.new(@config.content[:myepisodes_user],
                                  @config.content[:cookie])
      # Log in using cookie by default
      myepisodes.load_cookie
      shows = myepisodes.get_shows(date)
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
    # Returns the date from which to check for shows
    # Or nil if the date is today
    def check_date(offset)
      last = @config.content[:date]
      last -= offset
      last if last != Date.today
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
    # Iteratively applies filters until they've all been applied
    # or applying the next filter would result in no results
    # These filters are defined at @filters
    def filter_shows(links)
      @filters.each do |f| # Apply each filter
        new_links = links.reject { |name, _link| f.call(name) }
        # Stop if the filter removes every release
        break if new_links.empty?

        links = new_links
      end

      links
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
