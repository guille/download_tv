module DownloadTV
	class Configuration
		attr_reader :content
		
		def initialize
			if File.exists? "config.rb"
				@content = File.open("config", "rb") {|f| Marshal.load(f)}
			else
				@content = {}
				change_configuration
			end
		end


		def change_configuration
			if @content[:myepisodes_user]
				print "Enter your MyEpisodes username (#{@content[:myepisodes_user]}) : "
			else
				print "Enter your MyEpisodes username : "
			end
			@content[:myepisodes_user] = STDIN.gets.chomp
			puts

			print "Save cookie? (y)/n: "
			@content[:cookie] = STDIN.gets.chomp.downcase != "n"
			puts

			puts "Enter a comma-separated list of shows to ignore: (#{@content[:ignored]})"
			@content[:ignored] = STDIN.gets.chomp
			puts

			serialize()
		end

		def serialize()
			File.open("config", "wb") {|f| Marshal.dump(@content, f)}			
		end
	end
end