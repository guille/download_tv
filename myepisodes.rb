module ShowDownloader

	class MyEpisodes
		
		def MyEpisodes.get_shows(user, pass, last)
			agent = Mechanize.new

			page = agent.get "http://www.myepisodes.com/login.php"

			loginform = page.forms[1]
			loginform.username = user
			loginform.password = pass
			
			page = agent.submit(loginform, loginform.buttons.first)
			# Failed login
			if page.filename == "login.php"
				raise AuthenticationError
			end
			page = agent.get "http://www.myepisodes.com/ajax/service.php?mode=view_privatelist"
			shows = page.parser.css('tr.past')

			s = shows.select do |i|
				airdate = i.css('td.date')[0].text
				Date.parse(airdate) >= last
			end

			s.map do |i|
				name = i.css('td.showname').text
				ep = i.css('td.longnumber').text

				ep.insert(0, "S")
				ep.sub!("x", "E")

				"#{name} #{ep}"
			end
			
		end
		
	end

	class AuthenticationError < StandardError

	end

end