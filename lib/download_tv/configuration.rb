module DownloadTV
  ##
  # Class used for managing the configuration of the application
  class Configuration
    attr_reader :content, :config_path

    def initialize(content = {}, force_change = false)
      FileUtils.mkdir_p(File.join(ENV['HOME'], '.config', 'download_tv'))
      @config_path = content[:path] || File.join(ENV['HOME'], '.config', 'download_tv', 'config')

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
      if @content[:myepisodes_user]
        print "Enter your MyEpisodes username (#{@content[:myepisodes_user]}) : "
      else
        print 'Enter your MyEpisodes username: '
      end
      @content[:myepisodes_user] = STDIN.gets.chomp

      print 'Save cookie? (y)/n: '
      @content[:cookie] = !(STDIN.gets.chomp.casecmp? 'n')

      if @content[:ignored]
        puts "Enter a comma-separated list of shows to ignore: (#{@content[:ignored]})"
      else
        puts 'Enter a comma-separated list of shows to ignore: '
      end

      @content[:ignored] = STDIN.gets.chomp.split(',').map(&:strip).map(&:downcase)
      STDOUT.flush

      # When modifying existing config, keeps previous values
      # When creating new one, sets defaults
      @content[:auto] ||= true
      @content[:subs] ||= true
      @content[:grabber] ||= 'TorrentAPI'
      @content[:date] ||= Date.today - 1
      @content[:version] = DownloadTV::VERSION

      serialize
    end

    def serialize
      File.open(@config_path, 'wb') { |f| Marshal.dump(@content, f) }
    end

    def load_config
      @content = File.open(@config_path, 'rb') { |f| Marshal.load(f) }
      change_configuration if !@content[:version] || breaking_changes?(@content[:version])
    end

    ##
    # Returns true if a major or minor update has been detected
    # Returns false if a patch has been detected
    # Returns nil if it's the same version
    def breaking_changes?(version)
      DownloadTV::VERSION.split('.').zip(version.split('.')).find_index { |x, y| y > x }&.< 2
    end

    def print_config
      @content.each { |k, v| puts "#{k}: #{v}" }
    end
  end
end
