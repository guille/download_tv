module DownloadTV

	class Addic7ed < LinkGrabber
		def initialize
			super("http://www.addic7ed.com/search.php?search=%s&Submit=Search", "+")
		end

		def get_subs(show)
			url = get_url(show)
			download_file(url)
		end
		
		def get_url(show)
			# Change spaces for the separator
			s = show.gsub(" ", @sep)

			# Format the url
			search = @url % [s]

			agent = Mechanize.new
			res = agent.get(search)

			# No redirection means no subtitle found
			raise NoSubtitlesError if res.uri.to_s == search

			##########
			# DO OPENSUBTITLES FIRST (see subtitles.rb)
			#####

			# We now have an URL like:
			# http://www.addic7ed.com/serie/Mr._Robot/2/3/eps2.1k3rnel-pan1c.ksd

			# To find the real links:
			# see comments at the end of file


		end	

		def download_file(url)
			# Url must be like "http://www.addic7ed.com/updated/1/115337/0"

			# ADDIC7ED PROVIDES RSS

			agent = Mechanize.new
			page = agent.get(url2, [], @url)
			puts page.save("Hi")
			
		end
		
	end
end


# subtitles = {}
# html.css(".tabel95 .newsDate").each do |td|
# 	if downloads = td.text.match(/\s(\d*)\sDownloads/i)
# 		done = false
# 		td.parent.parent.xpath("./tr/td/a[@class='buttonDownload']/@href").each do |link|
# 			if md = link.value.match(/updated/i)
# 				subtitles[downloads[1].to_i] = link.value
# 				done = true
# 			elsif link.value.match(/original/i) && done == false
# 				subtitles[downloads[1].to_i] = link.value
# 				done = true
# 			end
# 		end
# 	end