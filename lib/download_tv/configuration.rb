module DownloadTV
	class Configuration
		attr_reader :content
		
		def initialize(force_change=false)
			if File.exists? "config"
				@content = File.open("config", "rb") {|f| Marshal.load(f)}
				change_configuration if force_change
			else
				@content = {}
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
			puts

			print "Save cookie? (y)/n: "
			@content[:cookie] = STDIN.gets.chomp.downcase != "n"
			puts

			if @content[:ignored]
				puts "Enter a comma-separated list of shows to ignore: (#{@content[:ignored]})"
			else
				puts "Enter a comma-separated list of shows to ignore: "
			end
			
			@content[:ignored] = STDIN.gets.chomp
			puts
			STDOUT.flush

			serialize()
		end

		def serialize()
			File.open("config", "wb") {|f| Marshal.dump(@content, f)}			
		end
	end
end