# frozen_string_literal: true

module DownloadTV
  ##
  # Class used for managing the configuration of the application
  class Configuration
    attr_reader :content, :config_path

    def initialize(content = {}, force_change = false)
      FileUtils.mkdir_p(File.join(ENV['HOME'], '.config', 'download_tv'))
      @config_path = content[:path] || default_config_path

      if File.exist? @config_path
        load_config
        @content.merge!(content) unless content.empty?
        @content[:ignored]&.map!(&:downcase)
        change_configuration if force_change
      else
        @content = content
        change_configuration
      end
    end

    def change_configuration
      prompt_for_myep_user
      prompt_for_cookie
      prompt_for_ignored
      STDOUT.flush

      set_default_values
      serialize
    end

    def prompt_for_myep_user
      if @content[:myepisodes_user]
        print "Enter your MyEpisodes username (#{@content[:myepisodes_user]}) : "
      else
        print 'Enter your MyEpisodes username: '
      end
      @content[:myepisodes_user] = STDIN.gets.chomp
    end

    def prompt_for_cookie
      print 'Save cookie? (y)/n: '
      @content[:cookie] = !(STDIN.gets.chomp.casecmp? 'n')
    end

    def prompt_for_ignored
      if @content[:ignored]
        puts "Enter a comma-separated list of shows to ignore: (#{@content[:ignored]})"
      else
        puts 'Enter a comma-separated list of shows to ignore: '
      end

      @content[:ignored] = STDIN.gets
                                .chomp
                                .split(',')
                                .map(&:strip)
                                .map(&:downcase)
    end

    def set_default_values
      # When modifying existing config, keeps previous values
      # When creating new one, sets defaults
      @content[:auto] ||= true
      @content[:subs] ||= true
      @content[:grabber] ||= 'TorrentAPI'
      @content[:date] ||= Date.today - 1
      @content[:pending] ||= []
      @content[:version] = DownloadTV::VERSION
    end

    def serialize
      @content[:pending] = @content[:pending].uniq
      File.write(@config_path, JSON.generate(@content))
    end

    def load_config
      source = File.read(@config_path)
      @content = JSON.parse(source, symbolize_names: true)

      @content[:date] = Date.parse(@content[:date]) if @content[:date]

      change_configuration if !@content[:version] || breaking_changes?(@content[:version])
    rescue JSON::ParserError
      @content = {}
      change_configuration
      retry
    end

    def default_config_path
      File.join(ENV['HOME'], '.config', 'download_tv', 'config')
    end

    ##
    # Returns true if a major or minor update has been detected
    # Returns false if a patch has been detected
    # Returns nil if it's the same version
    def breaking_changes?(version)
      DownloadTV::VERSION.split('.')
                         .zip(version.split('.'))
                         .find_index { |x, y| y < x }
                         &.< 2
    end

    def print_config
      @content.each { |k, v| puts "#{k}: #{v}" }
    end

    def print_attr(arg)
      puts @content[arg]
    end

    def clear_pending
      @content[:pending].clear
      serialize
    end
  end
end
