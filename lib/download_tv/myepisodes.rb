# frozen_string_literal: true

module DownloadTV
  ##
  # API wrapper for MyEpisodes
  class MyEpisodes
    def initialize(user, save_cookie)
      @agent = Mechanize.new
      @agent.user_agent = DownloadTV::USER_AGENT
      @user = user
      @save_cookie = save_cookie
      @cookie_path = File.join(ENV['HOME'], '.config', 'download_tv', 'cookie')
    end

    def login
      pass = prompt_user_data
      page = @agent.get 'https://www.myepisodes.com/login.php'

      login_form = page.forms[1]
      login_form.username = @user
      login_form.password = pass

      page = @agent.submit(login_form, login_form.buttons.first)

      raise InvalidLoginError if page.filename == 'login.php'

      save_cookie if @save_cookie

      @agent
    end

    def prompt_user_data
      if !@user || @user == ''
        print 'Enter your MyEpisodes username: '
        @user = STDIN.gets.chomp
      end

      print 'Enter your MyEpisodes password: '
      pass = STDIN.noecho(&:gets).chomp
      puts
      pass
    end

    def load_cookie
      if File.exist? @cookie_path
        @agent.cookie_jar.load @cookie_path
        return @agent if logged_in?

        puts 'The cookie is invalid/has expired.'
      else
        puts 'Cookie file not found'
      end

      login
    end

    def logged_in?
      page = @agent.get 'https://www.myepisodes.com/login.php'
      page.links[1].text == 'Register'
    end

    def save_cookie
      @agent.cookie_jar.save(@cookie_path, session: true)
      @agent
    end

    def get_shows(last)
      page = @agent.get 'https://www.myepisodes.com/ajax/service.php?mode=view_privatelist'
      shows = page.parser.css('tr.past')

      shows = filter_newer_shows(shows, last)

      build_show_strings(shows)
    end

    def filter_newer_shows(shows, date)
      shows.select do |i|
        airdate = i.css('td.date')[0].text
        Date.parse(airdate) >= date
      end
    end

    def build_show_strings(shows)
      shows.map do |i|
        sname = i.css('td.showname').text
        ep = i.css('td.longnumber').text

        ep.insert(0, 'S')
        ep.sub!('x', 'E')

        "#{sname} #{ep}"
      end
    end
  end

  class InvalidLoginError < StandardError; end
end
