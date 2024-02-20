# frozen_string_literal: true

module DownloadTV
  ##
  # Class used for managing the configuration of the application
  class Configuration
    def initialize(user_config = {})
      load_config(user_config)
    end

    def [](key)
      @content[key]
    end

    def []=(key, value)
      @content[key] = value
    end

    def change_configuration
      prompt_for_new_values
      set_default_values
      serialize
    end

    def serialize
      self[:pending] = self[:pending].uniq
      File.write(config_path, JSON.generate(@content))
    end

    def to_s
      @content.reduce('') do |mem, item|
        key, val = item
        "#{mem}#{key}: #{val}\n"
      end
    end

    def clear_pending
      self[:pending].clear
      serialize
    end

    def queue_pending(show)
      self[:pending] << show
      serialize
    end

    private

    def content
      @content ||= {}
    end

    def load_config(user_config)
      if File.exist? config_path
        parse_config
      else
        FileUtils.mkdir_p(File.expand_path('..', config_path))
        change_configuration
      end
      content.merge!(user_config) unless user_config.empty?
      self[:ignored]&.map!(&:downcase)
    end

    def parse_config
      source = File.read(config_path)
      @content = JSON.parse(source, symbolize_names: true)

      self[:date] = Date.parse(self[:date]) if self[:date]

      if !self[:version] || breaking_changes?(self[:version])
        warn 'Change configuration required (version with breaking changes detected)'
        change_configuration
      end
    rescue JSON::ParserError => e
      warn "Error parsing config file at #{config_path} => #{e.message}"
      change_configuration
    end

    ##
    # Returns true if a major or minor update has been detected, or if the config version is newer
    # than the installed version. Returns something falsy otherwise
    def breaking_changes?(version)
      paired = DownloadTV::VERSION.split('.')
                                  .map(&:to_i)
                                  .zip(version.split('.').map(&:to_i))
      # The configuration belongs to a newer version than is installed
      return true unless paired.find_index { |x, y| x < y }.nil?

      paired.find_index { |x, y| y < x }&.< 2
    end

    def prompt_for_new_values
      prompt_for_myep_user
      prompt_for_cookie
      prompt_for_ignored
      prompt_for_filters
      $stdout.flush
    end

    def prompt_for_myep_user
      existing = "(#{self[:myepisodes_user]}) " if self[:myepisodes_user]
      print "Enter your MyEpisodes username #{existing}: "
      input = $stdin.gets.chomp
      self[:myepisodes_user] = input if input
    end

    def prompt_for_cookie
      print 'Save cookie? (y)/n: '
      self[:cookie] = !($stdin.gets.chomp.casecmp? 'n')
    end

    def prompt_for_ignored
      existing = "(#{self[:ignored]})" if self[:ignored]
      puts "Enter a comma-separated list of shows to ignore: #{existing}"

      self[:ignored] = read_and_split_list :downcase
    end

    def prompt_for_filters
      puts "Current filters: (#{self[:filters]})" if self[:filters]
      self[:filters] = {}

      puts 'Enter a comma-separated list of terms to include: '
      self[:filters][:includes] = read_and_split_list :upcase

      puts 'Enter a comma-separated list of terms to exclude: '
      self[:filters][:excludes] = read_and_split_list :upcase
    end

    def config_path
      (content[:path] || default_config_path)
    end

    def default_config_path
      File.join(ENV['HOME'], '.config', 'download_tv', 'config')
    end

    ##
    # Update the +content+ attribute with the defaults, if needed.
    # Maintains the previous values, in case it's an update from an existing file.
    def set_default_values
      self[:auto] ||= true
      self[:grabber] ||= 'Torrentz'
      self[:date] ||= Date.today - 1
      self[:filters] ||= default_filters
      self[:pending] ||= []
      self[:version] = DownloadTV::VERSION
    end

    def default_filters
      {
        'includes' => %w[PROPER REPACK],
        'excludes' => []
      }
    end

    def read_and_split_list(case_method)
      $stdin.gets.chomp.split(',')
            .map(&:strip)
            .map(&case_method)
    end
  end
end
