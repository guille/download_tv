# frozen_string_literal: true

module DownloadTV
  ##
  # Class used for managing the configuration of the application
  class Configuration
    attr_reader :content, :config_path

    def initialize(content = {})
      @config_path = content[:path] || default_config_path
      FileUtils.mkdir_p(File.expand_path('..', @config_path))

      if File.exist? @config_path
        load_config
        @content.merge!(content) unless content.empty?
        @content[:ignored]&.map!(&:downcase)
      else
        @content = content
        change_configuration
      end
    end

    def change_configuration
      prompt_for_myep_user
      prompt_for_cookie
      prompt_for_ignored
      prompt_for_filters
      $stdout.flush

      set_default_values
      serialize
    end

    def prompt_for_myep_user
      existing = "(#{@content[:myepisodes_user]}) " if @content[:myepisodes_user]
      print "Enter your MyEpisodes username #{existing}: "
      input = $stdin.gets.chomp
      @content[:myepisodes_user] = input if input
    end

    def prompt_for_cookie
      print 'Save cookie? (y)/n: '
      @content[:cookie] = !($stdin.gets.chomp.casecmp? 'n')
    end

    def prompt_for_ignored
      existing = "(#{@content[:ignored]})" if @content[:ignored]
      puts "Enter a comma-separated list of shows to ignore: #{existing}"

      @content[:ignored] = read_and_split_list :downcase
    end

    def prompt_for_filters
      puts "Current filters: (#{@content[:filters]})" if @content[:filters]
      @content[:filters] = {}

      puts 'Enter a comma-separated list of terms to include: '
      @content[:filters][:includes] = read_and_split_list :upcase

      puts 'Enter a comma-separated list of terms to exclude: '
      @content[:filters][:excludes] = read_and_split_list :upcase
    end

    def read_and_split_list(case_method)
      $stdin.gets.chomp.split(',')
            .map(&:strip)
            .map(&case_method)
    end

    def default_filters
      {
        'includes' => %w[PROPER REPACK],
        'excludes' => %w[2160P 1080P 720P]
      }
    end

    ##
    # Update the +content+ attribute with the defaults, if needed.
    # Maintains the previous values, in case it's an update from an existing file.
    def set_default_values
      @content[:auto] ||= true
      @content[:grabber] ||= 'TorrentAPI'
      @content[:date] ||= Date.today - 1
      @content[:filters] ||= default_filters
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
    end

    def default_config_path
      File.join(ENV['HOME'], '.config', 'download_tv', 'config')
    end

    ##
    # Returns true if a major or minor update has been detected, something falsy otherwise
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

    def queue_pending(show)
      @content[:pending] << show
      serialize
    end
  end
end
