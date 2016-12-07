module ShowDownloader

	class MyEpisodes

		def MyEpisodes.login(user=nil, cookie_path="", save_cookie: true)
			agent = Mechanize.new

			# Try loading cookie
			return MyEpisodes.loadcookie(cookie_path) if File.exists? cookie_path

			if !user
				print "Enter your MyEpisodes username: "
				user = STDIN.gets.chomp
			end

			print "Enter your MyEpisodes password: "
			pass = STDIN.noecho(&:gets).chomp
			puts

			page = agent.get "https://www.myepisodes.com/login.php"

			login_form = page.forms[1]
			login_form.username = user
			login_form.password = pass

			page = agent.submit(login_form, login_form.buttons.first)

			raise InvalidLoginError if page.filename == "login.php"

			agent.cookie_jar.save(cookie_path, session: true) if save_cookie && cookie_path != ""

			[agent, page]
			
		end

		def MyEpisodes.loadcookie(cookie_path)
			agent = Mechanize.new
			agent.cookie_jar.load cookie_path
			agent

		end
		
		def MyEpisodes.get_shows(agent, last)
			page = agent.get "https://www.myepisodes.com/ajax/service.php?mode=view_privatelist"
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

	class InvalidLoginError < StandardError

	end

end