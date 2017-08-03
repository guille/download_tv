module DownloadTV

  class Subtitles

    def initialize
      @a = Addic7ed.new
      
    end

    def get_subs(show)
      @a.get_subs(show)

    rescue NoSubtitlesError
      puts "No subtitles found for #{show}"

    end
    
  end

end