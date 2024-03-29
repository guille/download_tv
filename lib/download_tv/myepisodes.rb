# frozen_string_literal: true

module DownloadTV
  ##
  # API wrapper for MyEpisodes
  class MyEpisodes
    def initialize(user, save_cookie)
      @user = user
      @save_cookie = save_cookie
      @cookie_path = File.join(ENV['HOME'], '.config', 'download_tv', 'cookie')
      agent.user_agent = DownloadTV::USER_AGENT
      login
    end

    def get_shows_since(last, include_tomorrow: false)
      page = agent.get 'https://www.myepisodes.com/ajax/service.php?mode=view_privatelist'
      shows = page.parser.css('tr.past')
      shows = filter_newer_shows(shows, last)
      shows.concat(page.parser.css('tr.today')) if include_tomorrow
      build_show_strings(shows)
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    def login
      logged_in_with_cookie = load_cookie
      manual_login unless logged_in_with_cookie
    end

    def manual_login
      pass = prompt_user_data
      page = agent.get 'https://www.myepisodes.com/login.php'

      login_form = page.forms[1]
      login_form.username = @user
      login_form.password = pass

      page = agent.submit(login_form, login_form.buttons.first)

      raise InvalidLoginError if page.filename == 'login.php'

      store_cookie if @save_cookie
    end

    ##
    # If there is a cookie file, tries to log in using it
    # returns the result of the operation (true/false)
    def load_cookie
      if File.exist? @cookie_path
        agent.cookie_jar.load @cookie_path
        return true if logged_in?

        puts 'The cookie is invalid/has expired.'
      else
        puts 'Cookie file not found'
      end

      false
    end

    def prompt_user_data
      if @user.nil? || @user.empty?
        print 'Enter your MyEpisodes username: '
        @user = $stdin.gets.chomp
      end

      print 'Enter your MyEpisodes password: '
      pass = $stdin.noecho(&:gets).chomp
      puts
      pass
    end

    def logged_in?
      page = agent.get 'https://www.myepisodes.com/login.php'
      page.links[1].text != 'Register'
    end

    def store_cookie
      agent.cookie_jar.save(@cookie_path, session: true)
    end

    # Only keep the shows that have aired since the given date
    def filter_newer_shows(shows, date)
      shows.select do |i|
        airdate = i.css('td.date')[0].text
        viewed_checkbox = i.css('td.status input').last
        Date.parse(airdate) >= date && viewed_checkbox&.attribute('checked').nil?
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
