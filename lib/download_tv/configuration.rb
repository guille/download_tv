module DownloadTV
	class Configuration
		attr_reader :content, :config_path
		
		def initialize(content={}, force_change=false)
			Dir.chdir(__dir__)

			@config_path = content[:path] || "config"
			
			if File.exist? @config_path
				@content = File.open(@config_path, "rb") { |f| Marshal.load(f) }
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
				print "Enter your MyEpisodes username: "
			end
			@content[:myepisodes_user] = STDIN.gets.chomp

			print "Save cookie? (y)/n: "
			@content[:cookie] = STDIN.gets.chomp.downcase != "n"

			if @content[:ignored]
				puts "Enter a comma-separated list of shows to ignore: (#{@content[:ignored]})"
			else
				puts "Enter a comma-separated list of shows to ignore: "
			end
			
			@content[:ignored] = STDIN.gets.chomp.split(",").map(&:strip).map(&:downcase)
			STDOUT.flush

			# When modifying existing config, keeps previous values
			# When creating new one, sets defaults
			@content[:auto] ||= true
			@content[:subs] ||= true
			@content[:grabber] ||= "TorrentAPI"

			serialize
		end


		def serialize
			File.open(@config_path, "wb") { |f| Marshal.dump(@content, f) }
		end
		

		def print_config
			@content.each {|k, v| puts "#{k}: #{v}"}
		end
	end
end