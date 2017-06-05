module ShowDownloader

	class MyEpisodes

		def initialize(user=nil, cookie_path="")
			@agent = Mechanize.new
			@user = user
			@cookie_path = cookie_path
			@save_cookie = cookie_path != ""
		end

		def login
			if !@user || @user==""
				print "Enter your MyEpisodes username: "
				@user = STDIN.gets.chomp
			end

			print "Enter your MyEpisodes password: "
			pass = STDIN.noecho(&:gets).chomp
			puts

			page = @agent.get "https://www.myepisodes.com/login.php"

			login_form = page.forms[1]
			login_form.username = @user
			login_form.password = pass

			page = @agent.submit(login_form, login_form.buttons.first)

			raise InvalidLoginError if page.filename == "login.php"

			save_cookie() if @save_cookie

			@agent
			
		end

		def load_cookie
			if File.exists? @cookie_path
				@agent.cookie_jar.load @cookie_path
				page = @agent.get "https://www.myepisodes.com/login.php"
				if page.links[1].text == "Register"
					puts "The cookie is invalid/has expired."
					login
				end
				@agent
			else
				puts "Cookie file not found"
				login
			end
			
		end

		def save_cookie
			@agent.cookie_jar.save(@cookie_path, session: true)
			@agent
			
		end
		
		def get_shows(last)
			page = @agent.get "https://www.myepisodes.com/ajax/service.php?mode=view_privatelist"
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